#!/usr/bin/gnuplot

if (!exists("user")) user='test'

corFile=user . '.cor'
outputFile=user . '.png'

reset

# png
set terminal pngcairo size 700,350 enhanced font 'Verdana,10'
set output outputFile

unset key
set border 0
unset tics
unset colorbox
set lmargin 0
set rmargin 0
set bmargin 0
set tmargin 0

set size ratio -1

plot 'NE2_50M_SR_W_700px.txt' w rgbimage, corFile with points lt 1 pt 2
