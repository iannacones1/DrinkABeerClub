#!/bin/bash

cd /home/pi/git/DrinkABeerClub/MapMaker

echo "MapMaker.bash..."

USER=$1

echo "Building WORLD for user: $USER"
gnuplot -e "user='$USER'" mapMaker.gnu
echo "Building USA for user: $USER"
gnuplot -e "user='$USER'" states.gnu
