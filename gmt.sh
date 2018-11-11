#!/bin/bash
gmt pscoast -R67/98/8/37 -JM5i -N1 -B5g5 -Gwhite -Scornflowerblue -Na -W1/0 -Cwhite -X2 -Y2 -K > data/2014_09.ps
gmt makecpt -Cgray -I -T0/35/0.5 -Z > ndt.cpt
gawk 'BEGIN {FS = ",";OFS = "," }; NR == 2 {max=$3}; NR > 1 {print $0,$3*0.4/max}' 2014_09.csv > 2014_09_size.csv
gmt psxy data/2014_09_size.csv -R -JM -O -K -W0.002 -Sc -Cndt.cpt >> data/2014_09.ps
#gmt psxy data/2014_09.csv -R -JM -O -K -W0.02 -Sc0.01 -Cndt.cpt >> data/2014_09.ps
gmt psscale -B10 -Dx2.5i/4.3i+w2i/0.5i+h -R67/98/8/37 -J -Cndt.cpt -I0.4 -By+lMbps -O >> data/2014_09.ps
ps2eps -f data/2014_09.ps
