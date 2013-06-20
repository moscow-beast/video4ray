#!/bin/bash
MAXWIDTH=860
MAXHEIGHT=480
EXTENSION_PATTERN="[MmAaFfWw][KkVvPpLlMm][VvIiGg4]" # Охватывет большую часть расширений видофайлов
AUDIO_BITRATE=128k # Зависит от версии ffmpeg или avconv
VIDEO_BITRATE=1024k # Зависит от версии ffmpeg или avconv
for FILE in *.$EXTENSION_PATTERN
do
    OUTSIZEX=$MAXWIDTH
    OUTSIZEY=$MAXHEIGHT
    eval $(avprobe -v 0 "$FILE" -show_streams  | grep -E 'width|height') # Подсмотрел. Устанавливает переменные ${width} и ${height} из оригинала.
# Вообще все что идет ниже, я писал в пике Балмера (xkcd.ru/323/), и хотя понимание осталось, объяснить попрошу кого-нибудь другого.
    WDEF=`echo "${width}/${MAXWIDTH}" | bc -l` # bash не умеет float. Не умеет float и bc. Но с ключем -l умеет
    HDEF=`echo "${height}/${MAXHEIGHT}" | bc -l`
    ISMS=`echo "(${HDEF}<${WDEF})" | bc -l` # Не могу объясить по человечески. Надеюсь вы мысль мою поняли.
    if [ $ISMS == 1 ]
    then
        OUTSIZEY=`echo "${height}/${WDEF}/2*2" | bc` # /2*2 и без ключа -l получается четное число, иначе ffmpeg обосрется
    else
        OUTSIZEX=`echo "${width}/${HDEF}/2*2" | bc`
    fi
# Пик Балмера кончился
    POSTFIX="-${OUTSIZEX}x${OUTSIZEY}.mp4"
# Зависит от версии ffmpeg или avconv. Собственно тут весь основной тюнинг:
    KEYS="-acodec libfaac -ac 2 -ar 48000 -b:a $AUDIO_BITRATE -vcodec libx264 -profile:v main -level 30 -refs 3 -flags2 -bpyramid -b:v $VIDEO_BITRATE -r 25 -s ${OUTSIZEX}x${OUTSIZEY} -threads 0 -aspect ${OUTSIZEX}:${OUTSIZEY} -map 0:0 -map 0:1"
    OUTNAME=`echo $FILE | sed s/\\\.$EXTENSION_PATTERN/$POSTFIX/g` # \\\Заэкранировали точку капитально, иначе может вкорячить постфикс в середину названия файла
    if [ -f ".$FILE.lock" ] # Что-бы не пытаться кодировать файлы закодированные до отключения электричества. Локи файла кодировавшегося во время инцедента и недокодированный огрызок нужно удалить вручную
    then
        echo "Файл заблокирован для транскодинга, пропускаем"
    else
        touch ".$FILE.lock"
        touch ".$OUTNAME.lock"
    # У меня на телефоне и/или в наушниках тихий звук, поэтому мы сначала вынем дорожку:
        avconv -i "$FILE" -ac 2 tmp.wav
    # Нормализуем ее sox'ом:
        sox tmp.wav tmp1.wav --norm --show-progress
        rm tmp.wav
    # Поехали!
        avconv -i "$FILE" -i tmp1.wav $KEYS -map 0:0 -map 1:0 "$OUTNAME"
        rm tmp1.wav
    fi
done
