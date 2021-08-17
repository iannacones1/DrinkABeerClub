#!/bin/bash

cd /home/pi/git/DrinkABeerClub/

NEED_TO_RUN=`find user_data -type f -newer /var/www/html/2021_helper.html -name "*_distinct_beers.csv"`

if [ -n "$NEED_TO_RUN" ]; then
    echo "Building new cheatsheet"
    #./cheatSheet.rb && mv cheatSheet.html /var/www/
    #./cheatSheet_unlimited.rb && mv cheatSheet_unlimited.html /var/www/
    #./cheatSheetRegion.rb && mv cheatSheet_unlimited.html /var/www/
    #./2018_cheatSheet.rb && mv cheatSheet_unlimited.html /var/www/html/
    ./2021_Helper.rb data/DE-MD-NJ-NY-PA_county_list.csv data/DE-MD-NJ-NY-PA_city_to_county.csv data/2021_Users.csv && mv 2021_helper.html /var/www/html/

else
    echo "No new distinct beers; no need to run"
fi
