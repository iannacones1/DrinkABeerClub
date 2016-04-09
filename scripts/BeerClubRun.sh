#!/bin/bash

LOCK_FILE="/home/pi/.DaBCDataLock"

if [ -e $LOCK_FILE ]; then

    echo "$LOCK_FILE LOCKED; exit"
    exit 1
fi

echo $(date)

echo $$ > $LOCK_FILE
echo "LOCK $LOCK_FILE"

cd /home/pi/git/DrinkABeerClub/scripts

./DataGrabber.sh | tee logs/DataGrapper.log

./HtmlWriter.sh | tee logs/HtmlWriter.log

./CheatSheet.bash | tee logs/CheatSheet.log

echo "UNLOCK $LOCK_FILE"
rm $LOCK_FILE

echo $(date)
