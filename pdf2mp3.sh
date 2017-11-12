#!/bin/bash

# TODO include install script as well

pdftotext $1
WAV=$(printf $1 | sed 's/\.pdf/.wav/g')
SLOW=$(printf $1 | sed 's/\.pdf/.slow.wav/g')
TXT=$(printf $1 | sed 's/\.pdf/.txt/g')
MP3=$(printf $1 | sed 's/\.pdf/.mp3/g')
#"$(cat $TXT)"
fmt --width=80 $TXT
# TODO line width doesnt seem to be the problem. total character count didnt really either, but maybe
# TODO see what special characters are breaking things (it doesn't seem to be happening)

# -w=./tmp.wav "$(awk 'NR==400, NR==700' cause_predict_search.txt)"

# not sure i need the second part
sed -e 's/[^a-zA-Z*0-9]/ /g;s/  */ /g' $TXT >$TXT.tmp
mv $TXT.tmp $TXT
#pico2wave --wave="$i$WAV" "$(cat $TXT)"

i=0
# TODO loop through text file in max # words / lines, then concat wav files with sox?
cat $TXT | while read line
do
    pico2wave --wave="$i$WAV" "$line"
    i=$((i+1))
done

#sox $WAV $SLOW speed 0.8
#avconv -i $SLOW $MP3
#rm -f $WAV $SLOW #$TXT
