#!/bin/bash

handleBadData ()
{
    echo 'handleBadData ()'

    rm -rf user_data
    cp -r user_data.bk user_data
    echo $(date) >> failover.log
    echo "----" >> failover.log

    exit 1
}

cd /home/pi/git/DrinkABeerClub

while IFS= read -r -d $'\0' file; do

    USER=`echo $file | rev | cut -d / -f 1 | rev | cut -d _ -f 1`
    echo "Updating users page for $USER"

#    ./BeersOfFame_SingleUser.rb $USER
#    if [[ $? -eq 0 ]]; then
#        mv $USER"_BoF.html" /var/www/$USER/
#    else
#        rm $USER"_BoF.html"
#        handleBadData
#    fi    

    ./FavBreweries.rb $USER > FavoriteBreweries.txt
    if [[ $? -eq 0 ]]; then
        mv FavoriteBreweries.txt /var/www/$USER/
    else
        rm FavoriteBreweries.txt
        handleBadData
    fi

    ./UserPage.rb $USER
    if [[ $? -eq 0 ]]; then
        mv $USER.html /var/www/$USER/
    else
        rm $USER.html
        handleBadData
    fi

done < <(find user_data -type f -newer /var/www/table.html -name "*_distinct_beers.csv" -print0)

UPDATE=`find user_data -type f -newer /var/www/table.html -name "*_checkins.csv"`

if [ -n "$UPDATE" ]; then

    echo 'Updating main table for all users'

    #2015
    cd /home/pi/git/DrinkABeerClub

    #./fileBased_2015.rb
    ./styleBased.rb 2016 data/styles2016.csv data/Users_2016.csv

    if [[ $? -eq 0 ]]; then
        mv table.html /var/www/table.html
        rm -rf user_data.bk
        cp -r user_data user_data.bk
    else
        rm table.html
        handleBadData
    fi

    ./BeersOfFame_AllUserTable.rb
    if [[ $? -eq 0 ]]; then
        mv "BeersOfFame.html" /var/www/
    else
        rm "BeersOfFame.html"
        handleBadData
    fi    

else
    echo 'No new user data; nothing to do'
fi