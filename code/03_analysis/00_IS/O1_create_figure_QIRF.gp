set terminal pdfcairo enhanced font "Arial,9" size 9,6
set output "../../../paper/figures/QIRF_plots.pdf"

set datafile separator ","

set multiplot layout 2,2
set grid
set key bottom center vertical
set border linewidth 1.5

set style line 1 lc rgb "#4d9aaa" lw 2      # QR  — muted teal
set style line 2 lc rgb "#f0923a" lw 2      # LSR — orange
set style line 3 lc rgb "#1a1a1a" lw 3      # OLS — black
set style line 4 lc rgb "#1a1a1a" lt 2 lw 1.5

set format y "%.2f"
# ---------------- RPI (row 1) ----------------
set title "RPI"
plot \
'OLS_CI.csv' using 15:1:8   with filledcurves lc rgb "#aaaaaa" fs transparent solid 0.3 notitle , \
'QR_IR.csv'  using 8:1      with lines linestyle 1 title "QR" , \
'LS_IR.csv'  using 8:1      with lines linestyle 2 title "LSR" , \
'OLS_IR.csv' using 8:1      with lines linestyle 3 title "Location-only"

# ---------------- INDPRO (row 2) ----------------
set title "INDPRO"
plot \
'OLS_CI.csv' using 15:2:9   with filledcurves lc rgb "#aaaaaa" fs transparent solid 0.3 notitle , \
'QR_IR.csv'  using 8:2      with lines linestyle 1 notitle , \
'LS_IR.csv'  using 8:2      with lines linestyle 2 notitle , \
'OLS_IR.csv' using 8:2      with lines linestyle 3 notitle
# ---------------- UNRATE (row 3) ----------------
set title "UNRATE"
plot \
'OLS_CI.csv' using 15:3:10  with filledcurves lc rgb "#aaaaaa" fs transparent solid 0.3 notitle , \
'QR_IR.csv'  using 8:3      with lines linestyle 1 notitle , \
'LS_IR.csv'  using 8:3      with lines linestyle 2 notitle , \
'OLS_IR.csv' using 8:3      with lines linestyle 3 notitle
# ---------------- CPI (row 6) ----------------
set title "CPI"
plot \
'OLS_CI.csv' using 15:6:13  with filledcurves lc rgb "#aaaaaa" fs transparent solid 0.3 notitle , \
'QR_IR.csv'  using 8:6      with lines linestyle 1 notitle , \
'LS_IR.csv'  using 8:6      with lines linestyle 2 notitle , \
'OLS_IR.csv' using 8:6      with lines linestyle 3 notitle

unset multiplot
unset output
