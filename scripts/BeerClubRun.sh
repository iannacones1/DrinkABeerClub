#!/bin/bash

LOCK_FILE="/home/pi/.DaBCDataLock"

if [ -e $LOCK_FILE ]; then
    #TODO: Lock file could be "old" ignore if older then x time
    echo "$LOCK_FILE LOCKED; exit"
    exit 1
fi

echo $(date)

echo $$ > $LOCK_FILE
echo "LOCK $LOCK_FILE"

cd /home/pi/git/DrinkABeerClub/scripts

./DataGrabber.sh | tee logs/DataGrapper.log

./Vintage.sh | tee logs/Vintage.log

./HtmlWriter.sh | tee logs/HtmlWriter.log

#./CheatSheet.bash | tee logs/CheatSheet.log

echo "UNLOCK $LOCK_FILE"
rm $LOCK_FILE

echo $(date)
