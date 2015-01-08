#!/bin/bash

echo "Testing Internet Connection..."
wget -q --tries=10 --timeout=0 --spider http://google.com > /dev/null
if [[ $? -eq 0 ]]; then
    echo "Online"
else
    echo "Offline"
    exit 1
fi

#USERPAGE
cd /home/pi/git/DrinkABeerClub

./UserPage.rb && mv *.html /var/www/

#MAPMAKER
if [[ $? -eq 0 ]]; then

    mv *.cor MapMaker/

    cd /home/pi/git/DrinkABeerClub/MapMaker

    ./MapMaker.bash && mv *.png /var/www/

    mv *.cor backup/

fi

#2014
cd /home/pi/git/DrinkABeerClub

./2015_Styles.rb && mv table.html /var/www/table.html