#!/bin/bash

cd /home/pi/git/DrinkABeerClub/MapMaker

echo "MapMaker.bash..."


for FILE in *.cor
do

    USER=${FILE%.cor}

    echo "Building WORLD for user: $USER"

    gnuplot -e "user='$USER'" mapMaker.gnu
    echo "Building USA for user: $USER"
    gnuplot -e "user='$USER'" states.gnu

done
