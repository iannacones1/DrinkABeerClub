#!/bin/bash

cd /home/pi/git/DrinkABeerClub/

NEED_TO_RUN=`find user_data -type f -newer /var/www/cheatSheet_unlimited.html -name "*_distinct_beers.csv"`

if [ -n "$NEED_TO_RUN" ]; then
    echo "Building new cheatsheet"
    #./cheatSheet.rb && mv cheatSheet.html /var/www/
    #./cheatSheet_unlimited.rb && mv cheatSheet_unlimited.html /var/www/
    ./cheatSheetRegion.rb && mv cheatSheet_unlimited.html /var/www/
else
    echo "No new distinct beers; no need to run"
fi
