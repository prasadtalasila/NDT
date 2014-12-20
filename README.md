

Note : All phrases in quotes are shell commands. <name> implies you must put a suitable name.

-----------------------
Getting Started
-----------------------

The project uses M-Lab's NDT test data (http://www.measurementlab.net/about , https://cloud.google.com/bigquery/docs/dataset-mlab). 

Installing Google Cloud SDK and BigQuery :

1) Go to https://cloud.google.com/sdk/ and follow the instructions - if the curl command doesn't work, download the .zip or .tar.gz file, extract it in your work folder. The location of the extracted folder (it's name will be google-cloud-sdk) should never change.

2) After installing, RESTART your terminal and authenticate to Google Cloud Platform using '$ gcloud auth login' via your Gmail username and password so that future work is stored in your project. Usage of the command can be found here - https://cloud.google.com/sdk/gcloud/reference/auth/login

3) Set your project using the command '$gcloud config set project <project-name>'.

4) A tutorial of bq command line tool can be found here : https://cloud.google.com/bigquery/bq-command-line-tool

-----------------------
Steps
-----------------------

1) Change current directory to the one which contains the shell script.

2) Use '$ chmod +x <filename>.sh' to change the permissions and allow execution of the shell scripts.

3) Execute the files using '$ ./<filename>.sh Destination_Path Month/Date'. The output files will be create in the destination you provide.


-----------------------
Specifications
-----------------------

To obtain the data for specific ISPs (this works well when the connection_spec.client_hostname is well populated, between 2009-2013), add an extra condition " AND connection_spec.client_hostname LIKE '%<company name>%' " in the WHERE clause of the bq command (line 7 of bash file). For example, the extra condition would be " AND connection_spec.client_hostname LIKE '%airtel%' " for extracting data for Bharti Airtel Pvt. Ltd. 

IMPORTANT NOTE : Do check the hostname output in the .csv file to see the hostnames of other companies and put an appropriate condition in the LIKE clause, all hostnames may not be exactly the name of the company.

-----------------------
Details of Shell Script
-----------------------

The file ndt_india.sh has two loops. The outer loop(year) controls the year being processed and the inner loop(month) the month.

grep,sed,cut and cat are used for removing the unneccessary top columns and other characters so that the file can be converted into .csv format.

pscoast and psxyz are GMT commands (http://gmt.soest.hawaii.edu/) used for plotting the .csv file.

ps2raster converts the .ps files obtained from psxyz into .jpg format to create the movie file.

The mv command converts the .jpg filename into a 5-bit representation, otherwise the ordering is incorrect for the convert command used next to create the movie (For example, 10 comes before 2 if only single or double bit representation is present, resulting in the month of October coming in before Februrary in the final clip).

Finally, the convert command runs when month is the last month entered, and it creates the movie clip taking all the above created .jpg files.


-----------------------
Future Work
-----------------------

Error checking in case the user enters a moth and year which is before July 2009 or after the current month can be added.

-------------------------------------------------------------------------------------------------------------------------------------------
