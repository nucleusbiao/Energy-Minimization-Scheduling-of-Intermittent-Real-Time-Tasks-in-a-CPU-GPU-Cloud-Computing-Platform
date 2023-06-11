set ylabel "Computation Time [s]" font ", 24" offset 0,0
set xlabel "Task Count" font ", 24" offset 0,-0.5

set ytics font ", 24"
set xtics font ", 24" offset 0, -0.3



set terminal postscript eps enhanced size 3,2.5 color
set output "figure/numTaskComTime.eps"

unset key # right top spacing 2 box width 6

set xrange [2:16]
set yrange [0.001:50]
# set format y "10^{%L}"
set logscale y
set grid

set xtics   ("2" 2,  "4" 4,  "6" 6,  "8" 8,  "10" 10, "12" 12,  "14" 14,  "16" 16,  "18" 18, "20" 20)
# set xtics   ("0.65" 0.65,  "0.75" 0.75,  "0.85" 0.85,  "0.95" 0.95)
# set style line 1 lc rgb '#0060ad' lt 4 lw 2 pt 2 ps 2   # --- blue

plot \
'data/numTaskComTime.txt' \
    using ($1):($2) title "{/=22 DP}"     with lp ps 3 lw 6 pt 5, \
''  using ($1):($3) title "{/=22 DPruntime}"     with lp ps 3 lw 6 pt 6, \
''  using ($1):($4) title "{/=22 Greedy1}"     with lp ps 3 lw 6 pt 8, \
''  using ($1):($5) title "{/=22 Greedy2}" 		with lp ps 3 lw 6 pt 4