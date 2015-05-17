#!/bin/bash
echo $(date)
minute=$(date +%M)
hour=$(date +%H)
hour=${hour#0}

cd /home/pi/git/DrinkABeerClub

USERS="data/Users.csv"

USER_COUNT=$(cat $USERS | wc -l)

echo "dbcWeb.bash running hour=$hour minute=$minute"

if [[ $hour -ne 0 ]] && [[ $hour -le $USER_COUNT ]]; then
  
    if [[ $minute -ne 0 ]] && [[ $minute -ne 30 ]]; then
        echo "Exiting hour=$hour minute=$minute"
        exit 1
    fi

fi



echo "Testing Internet Connection..."
wget -q --tries=10 --timeout=0 --spider http://google.com > /dev/null
if [[ $? -eq 0 ]]; then
    echo "Online"
else
    echo "Offline"
    exit 1
fi

echo "Collecting User Data..."

cd /home/pi/git/DrinkABeerClub

index=1

while read LINE; do

    USER=$(echo $LINE | cut -d "," -f 1)

    cd /home/pi/git/DrinkABeerClub

    # Once a day I want to clear out a users distinct beers
    # which will force the whole file to be rebuild
    # this is mostly because data on a beer can change over
    # time (e.g. Beer Label, Avg Rating)  
    if [[ $index -eq $hour ]] && [[ $minute -eq 0 ]]; then
       echo "Removing user_data for:" $USER
       rm "user_data/"$USER"_checkins.csv"
       rm "user_data/"$USER"_distinct_beers.csv"
    fi

    ./writeUserCheckins.rb $USER

    if [ -e $USER"_checkins.csv" ]; then

        mv $USER"_checkins.csv" user_data/ 

        ./writeUserDistinctBeers.rb $USER

        if [ -e $USER"_distinct_beers.csv" ]; then

            mv $USER"_distinct_beers.csv" user_data/ 

            ./fileBased_BeersOfFame.rb $USER
            ./FavBreweries.rb $USER > FavoriteBreweries.txt
            ./fileBasedUserPage.rb $USER

            if [[ $? -eq 0 ]]; then
                mv FavoriteBreweries.txt /var/www/$USER/
                mv $USER.html /var/www/$USER/
                mv $USER"_BoF.html" /var/www/$USER/
                mv $USER.cor MapMaker/

                cd MapMaker/

                ./MapMaker.bash $USER

                if [[ $? -eq 0 ]]; then
                    mv $USER.png /var/www/$USER/
                    mv $USER"_usa.png" /var/www/$USER/
                else
                    rm $USER.png
                    rm $USER"_usa.png"
                fi

                mv $USER.cor backup/

            else
                rm $USER.html
                rm $USER"_BoF.html"
                rm $USER.cor
            fi
        fi
    fi

    index=$[$index +1]

done < $USERS

#2015
cd /home/pi/git/DrinkABeerClub

./fileBased_2015.rb

if [[ $? -eq 0 ]]; then

    mv table.html /var/www/table.html

    rm -rf user_data.bk
    cp -r user_data user_data.bk 

else

    rm table.html

    rm -rf user_data
    cp -r user_data.bk user_data 
    echo $(date) >> failover.log
    echo "----" >> failover.log
fi

echo $(date)