#!/bin/bash

handleBadData ()
{
    echo 'handleBadData () '$1

    cd /home/pi/git/DrinkABeerClub

    rm -rf user_data.fail
    mv user_data user_data.fail
    cp -r user_data.bk user_data
    echo $(date) $1 >> failover.log
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
#        handleBadData $USER
#    fi    

    ./FavBreweries.rb $USER > FavoriteBreweries.txt
    if [[ $? -eq 0 ]]; then
        mv FavoriteBreweries.txt /var/www/html/$USER/
    else
        rm FavoriteBreweries.txt
        handleBadData $USER
    fi

    ./UserPage.rb $USER
    if [[ $? -eq 0 ]]; then
        mv $USER.html /var/www/html/$USER/
    else
        rm $USER.html
        handleBadData $USER
    fi

done < <(find user_data -type f -newer /var/www/html/table.html -name "*_distinct_beers.csv" -print0)

UPDATE=`find user_data -type f -newer /var/www/html/table.html -name "*_checkins.csv"`

if [ -n "$UPDATE" ]; then

    echo 'Updating main table for all users'

    #2015
    cd /home/pi/git/DrinkABeerClub

    #./fileBased_2015.rb
    #./styleBased.rb 2016 data/styles2016.csv data/Users_2016.csv
    #./regionStyleBased.rb 2017 data/2017_styles.csv data/Users_2016.csv data/Regions.csv
    #./2018_DaBC.rb 2018 data/2018_styles.csv data/2018_Users.csv data/2018_Regions.csv
    ./2019_DaBC.rb 2019 data/2019.csv data/2019_Users.csv

    if [[ $? -eq 0 ]]; then
        mv table.html /var/www/html/table.html
        rm -rf user_data.bk
        cp -r user_data user_data.bk
    else
        rm table.html
        handleBadData "table"
    fi

#    ./BeersOfFame_AllUserTable.rb
#    if [[ $? -eq 0 ]]; then
#        mv "BeersOfFame.html" /var/www/html/
#    else
#        rm "BeersOfFame.html"
#        handleBadData "table"
#    fi    

else
    echo 'No new user data; nothing to do'
fi
