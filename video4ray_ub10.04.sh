#!/bin/bash
MAXWIDTH=860
MAXHEIGHT=480
EXTENSION_PATTERN="[MmAaFfWw][KkVvPpLlMm][VvIiGg4]"
PRESET=normal
AUDIO_BITRATE=128k
VIDEO_BITRATE=1024k
for FILE in *.$EXTENSION_PATTERN
do
    OUTSIZEX=$MAXWIDTH
    OUTSIZEY=$MAXHEIGHT
    eval $(ffprobe -v 0 "$FILE" -show_streams  | grep -E 'width|height')
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
    KEYS="-acodec libfaac -ac 2 -ar 48000 -ab $AUDIO_BITRATE -vcodec libx264 -vpre $PRESET -vpre main -level 30 -refs 3 -flags2 -bpyramid -b $VIDEO_BITRATE -r 25 -s ${OUTSIZEX}x${OUTSIZEY} -threads 0 -aspect ${OUTSIZEX}:${OUTSIZEY}"
    OUTNAME=`echo $FILE | sed s/\\\.$EXTENSION_PATTERN/$POSTFIX/g`
    if [ -f ".$FILE.lock" ]
    then
        echo "File is locked. Skiping it"
    else
        touch ".$FILE.lock"
        touch ".$OUTNAME.lock"
           ffmpeg -i "$FILE" -ac 2 tmp.wav
           sox tmp.wav tmp1.wav --norm --show-progress
        rm tmp.wav
           ffmpeg -i "$FILE" -i tmp1.wav $KEYS -map 0:0 -map 1:0 "$OUTNAME"
        rm tmp1.wav
    fi
done
