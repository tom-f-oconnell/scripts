#!/usr/bin/env python3
"""
Copies everything under /mnt/d1/2p_data to Tom/2p_data on tensor or tensor-archive.

Files missing from the destination are copied without asking. Existing destination files
that rsync would replace (size or mtime differ from d1) are first compared by content:
identical ones are left alone, and different ones are only replaced after confirmation.
By default, each is asked about before copying starts. With --batch, everything else is
copied first, then all would-be replacements are listed and asked about once.

Replaced files are moved to <dest>/../2p_data_replaced/<timestamp>/, rather than deleted,
and nothing at the destination is deleted for being absent from d1. As with rsync's
default check, files with the same size and mtime on both sides are assumed identical
without being read.
"""

import argparse
import os
import re
import stat
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path


SRC = Path('/mnt/d1/2p_data')
DESTS = {
    'tensor': Path('/mnt/tensor/Tom/2p_data'),
    'tensor-archive': Path('/mnt/tensor-archive/Tom/2p_data'),
}

# Not preserving permissions / owner / group, so existing destination directories keep
# theirs (and the NFS server maps owner anyway). -8 to not escape non-ASCII in names.
RSYNC = ['rsync', '-rlt', '-8']

TYPE_NAMES = {stat.S_IFREG: 'file', stat.S_IFDIR: 'directory', stat.S_IFLNK: 'symlink'}


def unescape(name: bytes) -> str:
    """Undoes rsync's \\#ooo escaping of unprintable characters in output filenames.
    """
    return os.fsdecode(re.sub(rb'\\#([0-7]{3})', lambda m: bytes([int(m[1], 8)]), name))


def rsync_dry_run(dest: Path) -> list[tuple[str, str]]:
    """Returns (itemize code, path relative to SRC) for everything rsync would change.

    Also includes paths rsync would refuse to change because a non-empty directory is
    in the way, with code 'conflict' (rsync prints these as messages, not items).
    """
    proc = subprocess.run(
        RSYNC + ['--dry-run', '--out-format=%i\t%n', f'{SRC}/', f'{dest}/'],
        capture_output=True
    )
    items = []
    conflicts = set()
    other_errors = []
    for line in proc.stdout.splitlines() + proc.stderr.splitlines():
        if (m := re.match(rb'([^\t]{11})\t(.*)$', line)):
            items.append((m[1].decode(), unescape(m[2]).rstrip('/')))

        elif (m := re.match(rb'(?:cannot delete non-empty directory|could not make way '
                rb'for new .+?): (.*)$', line)):
            conflicts.add(unescape(m[1]))

        elif not line.startswith(b'rsync error: some files/attrs were not transferred'):
            other_errors.append(line.decode(errors='replace'))

    items.extend(('conflict', rel) for rel in sorted(conflicts))

    # 23 = some files not transferred, as when a directory is in the way (handled above)
    if proc.returncode not in (0, 23) or other_errors:
        sys.exit(f'rsync dry run failed (exit code {proc.returncode}):\n'
            + '\n'.join(other_errors)
        )
    return items


def same_contents(a: Path, b: Path, chunk_size: int = 16 * 2**20) -> bool:
    with open(a, 'rb') as fa, open(b, 'rb') as fb:
        while True:
            chunk = fa.read(chunk_size)
            if chunk != fb.read(chunk_size):
                return False
            if not chunk:
                return True


def classify(items: list[tuple[str, str]], dest: Path):
    """Sorts paths rsync would change into new / identical / different / type conflict.

    Returns:
        n_new: number of new regular files
        new_bytes: total size of those files
        identical: existing files rsync would replace, but with identical contents
            (only mtime differs)
        different: existing files / symlinks whose contents / targets differ
        conflicts: paths where destination has a different type of thing (e.g. a file
            where d1 has a directory). Never replaced by this script.
    """
    n_new = new_bytes = 0
    identical, different, conflicts, to_compare = [], [], [], []
    for code, rel in items:
        if code == 'conflict':
            if rel not in conflicts:
                conflicts.append(rel)
            continue

        s = os.lstat(SRC / rel)
        try:
            d = os.lstat(dest / rel)
        except FileNotFoundError:
            if stat.S_ISREG(s.st_mode):
                n_new += 1
                new_bytes += s.st_size
            continue
        # Under a path that is a file on dest, but a directory on d1 (a conflict, already
        # listed).
        except NotADirectoryError:
            continue

        if stat.S_IFMT(s.st_mode) != stat.S_IFMT(d.st_mode):
            if rel not in conflicts:
                conflicts.append(rel)

        # Only content transfers ('>'), not attribute-only changes ('.')
        elif stat.S_ISREG(s.st_mode) and code[0] == '>':
            if s.st_size != d.st_size:
                different.append(rel)
            else:
                to_compare.append((rel, s.st_size))

        elif stat.S_ISLNK(s.st_mode) and os.readlink(SRC / rel) != os.readlink(dest / rel):
            different.append(rel)

    total = sum(size for _, size in to_compare)
    done = 0
    for i, (rel, size) in enumerate(to_compare, 1):
        print(f'\rcomparing contents of same-size files: {i}/{len(to_compare)} '
            f'({fmt_bytes(done)} / {fmt_bytes(total)})', end='', flush=True
        )
        if same_contents(SRC / rel, dest / rel):
            identical.append(rel)
        else:
            different.append(rel)
        done += size
    if to_compare:
        print()

    return n_new, new_bytes, identical, sorted(different), sorted(conflicts)


def fmt_bytes(n: float) -> str:
    for unit in ('B', 'KB', 'MB', 'GB'):
        if n < 1000:
            return f'{n:.4g} {unit}'
        n /= 1000
    return f'{n:.4g} TB'


def describe(rel: str, dest: Path, dest_name: str) -> str:
    lines = [rel]
    for name, root in (('d1', SRC), (dest_name, dest)):
        path = root / rel
        st = os.lstat(path)
        if stat.S_ISLNK(st.st_mode):
            what = f'-> {os.readlink(path)}'
        elif stat.S_ISREG(st.st_mode):
            what = f'{st.st_size:,} bytes'
        else:
            what = TYPE_NAMES.get(stat.S_IFMT(st.st_mode), 'other')
        mtime = datetime.fromtimestamp(st.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
        lines.append(f'  {name + ":":<16}{what:>22}  modified {mtime}')
    return '\n'.join(lines)


def show_diff(rel: str, dest: Path, dest_name: str, max_lines: int = 200) -> None:
    out = subprocess.run(
        ['diff', '-u', '--label', f'{dest_name}/{rel}', '--label', f'd1/{rel}',
            dest / rel, SRC / rel
        ],
        capture_output=True, text=True, errors='replace'
    ).stdout.splitlines()
    print('\n'.join(out[:max_lines]))
    if len(out) > max_lines:
        print(f'... ({len(out) - max_lines} more lines)')


def ask(question: str, choices: str) -> str:
    while True:
        answer = input(question).strip().lower()
        if answer in choices and answer:
            return answer


def rsync(args: list[str]) -> int:
    print(' '.join(RSYNC + args))
    return subprocess.run(RSYNC + ['--info=progress2,stats1'] + args).returncode


def main():
    parser = argparse.ArgumentParser(description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument('dest', choices=list(DESTS))
    parser.add_argument('-b', '--batch', action='store_true', help='copy everything '
        'else first, then list all files that would be replaced and ask once'
    )
    args = parser.parse_args()

    # So output stays in order with rsync's, when redirected to a file
    sys.stdout.reconfigure(line_buffering=True)

    dest = DESTS[args.dest]
    assert dest.is_dir(), f'{dest} not mounted?'
    interactive = sys.stdin.isatty()

    print(f'checking what would change copying {SRC}/ -> {dest}/ ...')
    n_new, new_bytes, identical, different, conflicts = classify(
        rsync_dry_run(dest), dest
    )
    print(f'{n_new} new files ({fmt_bytes(new_bytes)}) to copy')
    print(f'{len(identical)} existing files have identical contents (only mtime '
        'differs). leaving these as-is.'
    )
    print(f'{len(different)} existing files differ from d1')
    if conflicts:
        print(f'{len(conflicts)} paths are a different type on {args.dest} (not '
            'replacing these. resolve by hand):'
        )
        for rel in conflicts:
            print(describe(rel, dest, args.dest))

    approved = []
    if different and not interactive:
        print('stdin is not a terminal, so not replacing any of them')

    elif different and not args.batch:
        for i, rel in enumerate(different, 1):
            print(f'\n[{i}/{len(different)}] {describe(rel, dest, args.dest)}')
            while (answer := ask('replace? [y]es, [n]o, [d]iff, [a]ll remaining, '
                    '[s]kip remaining: ', 'yndas')) == 'd':
                show_diff(rel, dest, args.dest)

            if answer in 'ya':
                approved.append(rel)
            if answer == 'a':
                approved.extend(different[i:])
            if answer in 'as':
                break
    print()

    failed = False
    rc = rsync(['--ignore-existing', f'{SRC}/', f'{dest}/'])
    # 23 is expected from the paths that are a different type on dest
    if rc != 0 and not (rc == 23 and conflicts):
        print('rsync failed copying new files', file=sys.stderr)
        failed = True

    if different and (args.batch or not interactive):
        print(f'\n{len(different)} existing files on {args.dest} differ from d1:')
        for rel in different:
            print(describe(rel, dest, args.dest))
        if (interactive and ask(f'replace all {len(different)} with the d1 versions? '
                '[y/n]: ', 'yn') == 'y'):
            approved = different

    if approved:
        backup_dir = (dest.parent / '2p_data_replaced'
            / datetime.now().strftime('%Y-%m-%d_%H%M%S')
        )
        with tempfile.NamedTemporaryFile() as f:
            f.write(b''.join(os.fsencode(rel) + b'\0' for rel in approved))
            f.flush()
            rc = rsync(['--files-from', f.name, '--from0', '--no-implied-dirs',
                '--backup', f'--backup-dir={backup_dir}', f'{SRC}/', f'{dest}/'
            ])
        if rc != 0:
            print('rsync failed replacing files', file=sys.stderr)
            failed = True
        print(f'replaced {len(approved)} files. old versions moved under {backup_dir}')

    if len(approved) < len(different):
        print(f'{len(different) - len(approved)} differing files NOT replaced')

    if failed:
        sys.exit(1)


if __name__ == '__main__':
    main()
