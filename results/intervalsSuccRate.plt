set ylabel "Success Rate" font ", 24" offset 0,0
set xlabel "Interval Count" font ", 24" offset 0,-0.5

set ytics font ", 24"
set xtics font ", 24" offset 0, -0.3



set terminal postscript eps enhanced size 3,2.5 color
set output "figure/intervalsSuccRate.eps"

unset key # left bottom spacing 2 box width 6

set xrange [10:100]
set yrange [0:1.1]
# set format y "10^{%L}"
# set logscale x
set grid

# set xtics   ("0.6" 0.6,  "0.65" 0.65,  "0.7" 0.7,  "0.75" 0.75,  "0.8" 0.8,  "0.85" 0.85,  "0.9" 0.9, "0.95" 0.95)
set xtics   ("10" 10, "20" 20, "30" 30, "40" 40, "50" 50, "60" 60, "70" 70, "80" 80, "90" 90, "100" 100)
# set style line 1 lc rgb '#0060ad' lt 4 lw 2 pt 2 ps 2   # --- blue

plot \
'data/intervalsSuccRate.txt' \
    using ($1):($2/100) title "{/=22 DP}"     with lp ps 3 lw 6 pt 5, \
''  using ($1):($3/100) title "{/=22 DPruntime}"     with lp ps 3 lw 6 pt 6, \
''  using ($1):($5/100) title "{/=22 Greedy1}"     with lp ps 3 lw 6 pt 8, \
''  using ($1):($6/100) title "{/=22 Greedy2}" 		with lp ps 3 lw 6 pt 4, \
''  using ($1):($4/100) title "{/=22 Random}"     with lp ps 3 lw 6 pt 10