#!/bin/bash

minute=$(date +%-M)
hour=$(date +%-H)

cd /home/pi/git/DrinkABeerClub

USERS="data/2020_DataUsers.csv"

USER_COUNT=$(cat $USERS | wc -l)

echo "<<<<< ENTER DATA GRABBER >>>>>"
echo "<<<<< $hour:$minute >>>>>"

if [[ $hour -ge $USER_COUNT ]] || [[ $minute -eq 0 ]]; then

    echo "Collecting User Data..."

    cd /home/pi/git/DrinkABeerClub

    index=0

    while read LINE; do

        USER=$(echo $LINE | cut -d "," -f 1)

        # Once a day I want to clear out a users distinct beers
        # which will force the whole file to be rebuild
        # this is mostly because data on a beer can change over
        # time (e.g. Beer Label, Avg Rating)
        if [[ $index -eq $hour ]]; then
           echo "Removing user_data for:" $USER
           #rm "user_data/"$USER"_checkins.csv"
           #rm "user_data/"$USER"_distinct_beers.csv"
           echo "" > "user_data/"$USER"_checkins.csv"
           echo "" > "user_data/"$USER"_distinct_beers.csv"
	   sleep $index
        fi

        ./writeUserCheckins.rb $USER

        if [[ $? -ne 0 ]]; then
            if [ -e $USER"_checkins.csv" ]; then
                rm $USER"_checkins.csv"
            fi
            echo "issue write user checkins: $USER; exit"
	    echo "<<<<< EXIT DATA GRABBER >>>>>"
            exit 1
        fi

        if [[ ! -e "user_data/"$USER"_distinct_beers.csv" || -e $USER"_checkins.csv" ]]; then

            if [ -e $USER"_checkins.csv" ]; then
                mv $USER"_checkins.csv" user_data/
            fi

            ./writeUserDistinctBeers.rb $USER

            if [[ $? -ne 0 ]]; then
                if [ -e $USER"_distinct_beers.csv" ]; then
                    rm $USER"_distinct_beers.csv"
                fi
                echo "issue write user distinct: $USER; exit"
		echo "<<<<< EXIT DATA GRABBER >>>>>"
                exit 1
            fi

            if [ -e $USER"_distinct_beers.csv" ]; then
                mv $USER"_distinct_beers.csv" user_data/
            fi
        fi

        index=$[$index +1]

    done < $USERS
else

    echo "Skipping Time: $hour:$minute"

fi
echo "<<<<< EXIT DATA GRABBER >>>>>"
