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

# Outer loop runs from 2009 to the end year taken from input.

for ((year=9; year<=input_endyear; year++)); do
	if [ $year -eq $input_endyear ]
		then
			# Inner loop has two conditions : runs till the last required month entered if the end year has been reached.
			for ((month=1; month<=input_endmonth; month++)); do
				# Year converted to 2 bit number and stored in variable year2.
				year2=$(printf "%02d" $year)
				
				# Year converted to 2 bit number and stored in variable year2.
				month2=$(printf "%02d" $month)

				# if condition to ensure datq for 2009 starts only from July onwards.
				if [[ $year -eq 9 && $month  -lt 7 ]]
				then
 					continue
				else
				# BigQuery to get data from M-Lab server. Table name modified to new one.
				bq query --max_rows 1000000 "SELECT connection_spec.client_geolocation.longitude AS LONGITUDE,
												connection_spec.client_geolocation.latitude AS LATITUDE,
												(avg(web100_log_entry.snap.HCDataOctetsOut))/(8*(sum(web100_log_entry.snap.SndLimTransRwin + web100_log_entry.snap.SndLimTransCwnd + web100_log_entry.snap.SndLimTransSnd))) AS THROUGHPUT, 
												web100_log_entry.snap.RemAddress AS IP,
												connection_spec.client_hostname AS NAME 
											FROM plx.google:m_lab.20${year2}_${month2}.all 
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
				cut -d " " -f 2- $path/20${year2}_${month}.csv | sponge $path/20${year2}_${month}.csv
				cat $path/20${year2}_${month}.csv | tr "|" "," | sponge $path/20${year2}_${month}.csv
				# pscoast creates map of India.				
				pscoast -R67/98/8/37 -JM6i -P -N1 -B5g5 -Gwhite -Sblue -Na -W -p135/40 -Cwhite -Xf -Yf -K> $path/20${year2}_${month}.ps
				# psxyz plots the data taken from the .csv file into the India map.
				gmt psxyz $path/20${year2}_${month}.csv -R67/98/8/37/0/100 -Jx0.5c -Jz1 -So0.18c -Ggreen -W -p135/40/100 -L -K -O -P -Xf -Yf >> $path/20${year2}_${month}.ps;
				# pstext plots the month and year on top of the India map.
				echo "4.5 8.15 33 1 5 BC $month 20$year2" | pstext -R0/11/0/8.5 -Jx1i -O >> $path/20${year2}_${month}.ps;
				# psconvert converts .ps file to .jpg file. 				
				psconvert  $path/20${year2}_${month}.ps -Tj
				# 5 digit representation taken to ensure movie clip is made in order.
				five_digit_representation=$(printf "%05d" $month)
				# renaming the file according to the five digit representation.
				mv $path/20${year2}_${month}.jpg $path/20${year2}_${five_digit_representation}.jpg
				# Status message to user.
				echo Finished month $month of year 20$year2
		fi
		# Create a movie clip at the end comprising all images (.jpg files).
		if [[ $year -eq $input_endyear && $month -eq $input_endmonth ]]
			then
				convert $(for a in $path/*.jpg; do printf -- "-delay 200 %s " $a; done; ) $path/movie.gif
		fi
	done;

		# Otherwise, inner loop runs from January to December (1-12). ALl other functionalities are the same.
		else
			for ((month=1; month<=12; month++)); do
				year2=$(printf "%02d" $year)
				month2=$(printf "%02d" $month)
				if [[ $year -eq 9 && $month  -lt 7 ]]
				then
 					continue
				else
				bq query --max_rows 1000000 "SELECT connection_spec.client_geolocation.longitude AS	LONGITUDE,
												connection_spec.client_geolocation.latitude AS LATITUDE,
												(avg(web100_log_entry.snap.HCDataOctetsOut))/(8*(sum(web100_log_entry.snap.SndLimTransRwin + web100_log_entry.snap.SndLimTransCwnd + web100_log_entry.snap.SndLimTransSnd ))) AS THROUGHPUT, 
												web100_log_entry.snap.RemAddress AS IP,
												connection_spec.client_hostname AS NAME 
											FROM plx.google:m_lab.20${year2}_${month2}.all 
											WHERE IS_EXPLICITLY_DEFINED(web100_log_entry.connection_spec.remote_ip) 
												AND IS_EXPLICITLY_DEFINED(web100_log_entry.log_time) 
												AND project=0 
												AND connection_spec.client_geolocation.country_code = 'IN' 
												AND connection_spec.client_geolocation.latitude NOT BETWEEN 19.99 AND 20.01  
												AND connection_spec.client_geolocation.longitude NOT BETWEEN 76.99 AND 77.01 
												GROUP BY IP,NAME,LONGITUDE,LATITUDE 
												ORDER BY THROUGHPUT DESC;" > $path/20${year2}_${month}.csv;
				grep -v ^+ $path/20${year2}_${month}.csv | sponge $path/20${year2}_${month}.csv
				sed -i '1d' $path/20${year2}_${month}.csv
				cut -d " " -f 2- $path/20${year2}_${month}.csv | sponge $path/20${year2}_${month}.csv
				cat $path/20${year2}_${month}.csv | tr "|" "," | sponge $path/20${year2}_${month}.csv
				pscoast -R67/98/8/37 -JM6i -P -N1 -B5g5 -Gwhite -Sblue -Na -W -p135/40 -Cwhite -Xf -Yf -K> $path/20${year2}_${month}.ps
				gmt psxyz $path/20${year2}_${month}.csv -R67/98/8/37/0/100 -Jx0.5c -Jz1 -So0.18c -Ggreen -W -p135/40/100 -L -K -O -P -Xf -Yf >> $path/20${year2}_${month}.ps;
				echo "4.5 8.15 33 1 5 BC $month 20$year2" | pstext -R0/11/0/8.5 -Jx1i -O >> $path/20${year2}_${month}.ps;
				psconvert  $path/20${year2}_${month}.ps -Tj
				five_digit_representation=$(printf "%05d" $month)
				mv $path/20${year2}_${month}.jpg $path/20${year2}_${five_digit_representation}.jpg
				echo Finished month $month of year 20$year2
			fi
		done;
	fi
done;
