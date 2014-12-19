#!/bin/bash

#USERPAGE
cd /home/pi/git/DrinkABeerClub

./UserPage.rb && mv *.html /var/www/ && mv *.cor MapMaker/

cd /home/pi/git/DrinkABeerClub/MapMaker

./MapMaker.bash && mv *.png /var/www/ && mv *.cor backup/

#2014
cd /home/pi/git/DrinkABeerClub

./2014_50States.rb && mv table.html /var/www/table.html
