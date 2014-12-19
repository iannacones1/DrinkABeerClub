#!/usr/bin/gnuplot

if (!exists("user")) user='test'

corFile=user . '.cor'
outputFile=user . '_usa.png'

reset

set term png
set terminal pngcairo size 700,524 enhanced
set output outputFile

# color definitions
set style line 1 lc rgb '#000000' lt 1 lw 1

unset key
set border 0
unset tics
set tmargin 0
set bmargin 0
set lmargin 0
set rmargin 0

set xrange [-125:-66.7]    
set yrange [24:55]
set size ratio -1

set multiplot
plot for [idx=0:48] 'usa.txt' i idx u 2:1 w l ls 1, corFile with points lt 1 pt 2
#plot 'usa.txt' u 2:1 w l ls 1, corFile with points lt 1 pt 2

unset label
# Alaska
set size 0.4,0.4
set origin 0,0
set xrange [-180:-120]
set yrange [50:75]
plot 'usa.txt' i 50 u 2:1 w l ls 1, corFile with points lt 1 pt 2
# Hawaii
set origin 0.1,0
set xrange [-180:-150]
set yrange [18:29]
plot 'usa.txt' i 49 u 2:1 w l ls 1, corFile with points lt 1 pt 2

replot

unset multiplot
