#!/bin/bash

#title           :ndt_india.sh
#description     :This script will take two inputs - the first will be the path to the destination folder and the second will be the month 			  and year seperated by a forward slash (/). The year should be a two digit value and the month can be a single digit or 			  two digit value. The script will output the .ps,.jpg and .csv files to the destination folder and will create a .gif 			  file of the obtained .jpg images.
#author		 :Sukanto Guha, Dhruv Shekhawat
#date            :2014/12/19
#version         :1.0
#usage		 :./ndt_india.sh Path_To_Destination Month/Year(2-digit)
#notes           :Install BigQuery and GMT to use this script.
#bash_version    :4.3.8(1)-release
#==============================================================================

set -x

# First argument should be the path to destination folder.
path=$1

# The second argument should be teh month and year till which the script should run.
end_date=$2

# Separate the two parts of end_date into two variables.
input_endmonth="$( cut -d '/' -f 1 <<< "$end_date" )"
input_endyear="$( cut -d '/' -f 2 <<< "$end_date" )"

# Check if the appropriate number of arguments are entered, else exit.
if [ ! $# == 2 ]; then
	echo "Usage: $0 Path_to_Destination_Folder Month/Year"
	echo "Example : $0 ~/user/ndt 8/13"
  	exit
fi

# Create a gray palette to indicate throughput
# when needed, increase the maximum value to the highest possible throughput
gmt makecpt -Cgray -I -T0/35/0.5 -Z > ndt.cpt

# Outer loop runs from 2009 to the end year taken from input.

for ((year=9; year<=input_endyear; year++)); do
		# Year converted to 2 bit number and stored in variable year2.
		year2=$(printf "%02d" $year)
		month="09"
		# BigQuery to get data from M-Lab server. Table name modified to new one.
		bq query --max_rows 1000000 "SELECT connection_spec.client_geolocation.longitude AS LONGITUDE,
												connection_spec.client_geolocation.latitude AS LATITUDE,
												(avg(web100_log_entry.snap.HCDataOctetsOut))/(8*(sum(web100_log_entry.snap.SndLimTransRwin + web100_log_entry.snap.SndLimTransCwnd + web100_log_entry.snap.SndLimTransSnd))) AS THROUGHPUT,
												web100_log_entry.snap.RemAddress AS IP,
												connection_spec.client_hostname AS NAME
											FROM plx.google:m_lab.20${year2}_${month}.all
											WHERE IS_EXPLICITLY_DEFINED(web100_log_entry.connection_spec.remote_ip)
												AND IS_EXPLICITLY_DEFINED(web100_log_entry.log_time)
												AND project=0
												AND connection_spec.client_geolocation.country_code = 'IN'
												AND connection_spec.client_geolocation.latitude NOT BETWEEN 19.99 AND 20.01
												AND connection_spec.client_geolocation.longitude NOT BETWEEN 76.99 AND 77.01
											GROUP BY IP,NAME,LONGITUDE,LATITUDE
											ORDER BY THROUGHPUT DESC;" > $path/20${year2}_${month}.csv;

		# grep, sed, cut and cat commands are to clean up and retain only the data in the .csv file - removes 					  column names, waiting statements, delimiters.
		grep -v ^+ $path/20${year2}_${month}.csv | sponge $path/20${year2}_${month}.csv
		sed -i '1d' $path/20${year2}_${month}.csv
		cut -d " " -f 2-4 $path/20${year2}_${month}.csv | sponge $path/20${year2}_${month}.csv
		cat $path/20${year2}_${month}.csv | tr "|" "," | sponge $path/20${year2}_${month}.csv

		# pscoast creates map of India.
		gmt pscoast -R67/98/8/37 -JM5i -N1 -B5g5 -Gwhite -Scornflowerblue -Na -W1/0 -Cwhite -X2 -Y2 -K > $path/20${year2}_${month}.ps
		# normalize the radius of the circles
		gawk 'BEGIN {FS = ",";OFS = "," }; NR == 2 {max=$3}; NR > 1 {print $0,$3*0.4/max}' $path/20${year2}_${month}.csv > $path/20${year2}_${month}_size.csv
		# psxy plots the data taken from the .csv file into the India map.
		gmt psxy $path/20${year2}_${month}_size.csv -R -JM -O -K -W0.002 -Sc -Cndt.cpt >> $path/20${year2}_${month}.ps
		#gmt psxy data/2014_09.csv -R -JM -O -K -W0.02 -Sc0.01 -Cndt.cpt >> data/2014_09.ps
		gmt psscale -B10 -Dx2.5i/4.3i+w2i/0.5i+h -R67/98/8/37 -J -Cndt.cpt -I0.4 -By+lMbps -O >> $path/20${year2}_${month}.ps

		ps2eps -f $path/20${year2}_${month}.ps
		# pstext plots the month and year on top of the India map.
		#echo "4.5 8.15 33 1 5 BC $month 20$year2" | pstext -R0/11/0/8.5 -Jx1i -O >> $path/20${year2}_${month}.ps;

		echo Finished month $month of year 20$year2
done;


#gmt pscoast -R67/98/8/37 -JM5i -N1 -B5g5 -Gwhite -Scornflowerblue -Na -W1/0 -Cwhite -X2 -Y2 -K > data/2009_09.ps
#gmt psxy data/2014_09.csv -R -JM -O -K -W1 -Sc0.2 -Ccopper.cpt >> data/2009_09.ps
#gmt psscale -DjTC+w5i/0.25i+h+o0/-1i -R67/98/8/37 -J -Ccopper.cpt -I0.4 -By+lm -O -K >> data/2009_09.ps
#ps2eps data/2009_09.ps		#removes the extra whitespace
#import to OpenOffice Draw, add axes and collate
# or put sub-figs in latex figure
# also try tikz figure(s) with text

#gmt change the page size / add multiple images in one file using x and y offsets
#normalize the THROUGHPUT values to show variation on heatmap
