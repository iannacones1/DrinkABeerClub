#!/usr/bin/gnuplot

if (!exists("user")) user='test'

corFile=user . '.cor'
outputFile=user . '.png'
unset key
unset border
unset yzeroaxis
unset xtics
unset ytics

plot 'world.dat' with lines lt 3 , corFile with points lt 1 pt 2

#plot 'world.dat' with lines lt 3
set title ""
#set key on
#set border

#set yzeroaxis
#set xtics
#set ytics
set term png
set output outputFile

replot