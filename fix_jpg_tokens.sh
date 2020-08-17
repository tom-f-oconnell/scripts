#!/usr/bin/env bash

FVTT_TOKEN_PATH="$HOME/shared/FoundryVTT/Data/tokens"
if [ ! -d "${FVTT_TOKEN_PATH}" ]; then
    echo "token path ${FVTT_TOKEN_PATH} did not exist!"
fi

OUTPUT_PATH="${FVTT_TOKEN_PATH}/converted_pngs"
# Needs to be already made for mogrify to not fail, it seems.
mkdir -p "${OUTPUT_PATH}"

echo "Saving modified tokens to ${OUTPUT_PATH}"

# The 20% fuzz is sufficient to get rid of the darker parts of the roll20
# watermark, I've found, though it is on the aggressive side, and can affect
# other parts of the image more than I'd like...

# Could also try floodfilling type stuff mentioned here?
# They also talk about morphology options (erode / dilate), which might also be
# useful. Just more complicated.
# http://www.imagemagick.org/discourse-server/viewtopic.php?t=33589&start=15
# (all mainly to get away with a less aggressive fuzz percentage, to affect the
# rest of the images less)

mogrify -format png -path "${OUTPUT_PATH}" -fuzz 20%% -transparent white \
    "${FVTT_TOKEN_PATH}/*.jp*g"

