#!/bin/bash

#USERPAGE
cd /home/pi/git/DrinkABeerClub

./UserPage.rb && mv *.html /var/www/

#MAPMAKER
mv *.cor MapMaker/

cd /home/pi/git/DrinkABeerClub/MapMaker

./MapMaker.bash && mv *.png /var/www/

#2014
cd /home/pi/git/DrinkABeerClub

./2014_50States.rb && mv table.html /var/www/table.html
