#!/bin/bash
MAXWIDTH=860
MAXHEIGHT=480
EXTENSION_PATTERN="[MmAaFfWw][KkVvPpLlMm][VvIiGg4]"
AUDIO_BITRATE=128k
VIDEO_BITRATE=1024k
for FILE in *.$EXTENSION_PATTERN
do
    OUTSIZEX=$MAXWIDTH
    OUTSIZEY=$MAXHEIGHT
    eval $(avprobe -v 0 "$FILE" -show_streams  | grep -E 'width|height')
    WDEF=`echo "${width}/${MAXWIDTH}" | bc -l`
    HDEF=`echo "${height}/${MAXHEIGHT}" | bc -l`
    ISMS=`echo "(${HDEF}<${WDEF})" | bc -l`
    if [ $ISMS == 1 ]
    then
        OUTSIZEY=`echo "${height}/${WDEF}/2*2" | bc`
    else
        OUTSIZEX=`echo "${width}/${HDEF}/2*2" | bc`
    fi
    POSTFIX="-${OUTSIZEX}x${OUTSIZEY}.mp4"
    KEYS="-acodec libfaac -ac 2 -ar 48000 -b:a $AUDIO_BITRATE -vcodec libx264 -profile:v main -level 30 -refs 3 -flags2 -bpyramid -b:v $VIDEO_BITRATE -r 25 -s ${OUTSIZEX}x${OUTSIZEY} -threads 0 -aspect ${OUTSIZEX}:${OUTSIZEY}"
    OUTNAME=`echo $FILE | sed s/\\\.$EXTENSION_PATTERN/$POSTFIX/g`
    if [ -f ".$FILE.lock" ]
    then
        echo "File is locked. Skiping it"
    else
        touch ".$FILE.lock"
        touch ".$OUTNAME.lock"
           avconv -i "$FILE" -ac 2 -map 0:a:0 tmp.wav
           sox tmp.wav tmp1.wav --norm --show-progress
        rm tmp.wav
           avconv -i "$FILE" -i tmp1.wav $KEYS -map 0:0 -map 1:0 "$OUTNAME"
        rm tmp1.wav
    fi
done
