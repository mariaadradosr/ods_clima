#!/bin/bash
#
# Recorre todos los archivos del directorio actual y los muestra
#bash preprocessing_aemet.sh 2020 05

#sudo apt install unrar
#sudo apt-get --fix-broken install
#sudo apt-get install gnumeric

REGEX=[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]
SEPARATOR_DATE=- 
ANYO=$1
MES=$2
FECHA=$ANYO"-"$MES
l=5

URL="https://datosclima.es/capturadatos/Aemet"$FECHA".rar"
echo $URL
mkdir -p aemetXls
wget $URL
unrar x ./Aemet$FECHA.rar ./aemetXls/
rm -r ./Aemet$FECHA.rar



#Recorre toda la ruta donde estén los ficheros Aemet
#Extrae la fecha del nombre del fichero

RUTA="./aemetXls"

for i in $(ls $RUTA | egrep '*.xls')
do

	FILEPATH=$i
	FILENAME=$(echo $FILEPATH | cut -d '.' -f 1)
	DATE_EXTRACTED=$(echo $FILEPATH | grep -oE $REGEX)
	DATE_EXTRACTED_MODIFY=$(echo $DATE_EXTRACTED | tr $SEPARATOR_DATE '-')
	
	mkdir -p $RUTA/csv
	ssconvert $RUTA/$i $RUTA/csv/$FILENAME.csv
	
	#carpeta donde se depositarán los ficheros con la fecha incluida dentro del mismo
	mkdir -p $RUTA/csv_with_dates
	
	awk -v var="$DATE_EXTRACTED_MODIFY" 'BEGIN{FS=OFS=","}{print var OFS $0}' $RUTA/csv/$FILENAME.csv>$RUTA/csv_with_dates/$FILENAME.csv
	
	#carpeta donde se depositaran los ficheros con la fecha y sin cabezera.
	mkdir -p $RUTA/csv_with_dates_without_header
	#delete number of header lines from file
	sed "1,$l"'d' $RUTA/csv_with_dates/$FILENAME.csv> $RUTA/csv_with_dates_without_header/$FILENAME.csv
done

cat $RUTA/csv_with_dates_without_header/* > ODS_35_$ANYO$MES.csv
rm -r ./*Xls*



 
 
