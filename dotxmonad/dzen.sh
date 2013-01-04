#!/bin/zsh

UPDATE=1

while :; do
    DATE=`date +"%a %b %d %T %Z %Y"`
    BATEMP=`acpi -b`
    COUNT=${BATEMP//[^.]/}
    if [[ ${(c)#COUNT} = 2 ]]; then
        BATTERY=`echo $BATEMP | sed 's/.*: //; s ,[^,]*$  '`
    else
        BATTERY=`echo $BATEMP | sed 's/.*: //'`
    fi
    echo "^fg(white)$BATTERY^fg() | ^fg(white)$DATE^fg()"
    sleep $UPDATE
done | dzen2 -fn '-*-liberation mono-medium-r-*-*-11-*-*-*-*-*-*-*' -bg '#2d2d2d' -fg '#000000' -ta r -p -y -1 -x -480 -title-name 'dzen right'
