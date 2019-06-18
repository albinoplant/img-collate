#!/bin/bash

#method that gets from user dir to organise and year of creation of oldest file
files () {
echo "Where are the files you want me to organise?"
read -p "" whereVar
#finds oldest file and puts its creation year in $dateVar
dateVar=$(find $whereVar -type f -printf '%T+ %p\n' | sort | head -n 1)
dateVar=${dateVar::4}
}

#same as file function but it takes only photo extentions
photos () {
echo "Where are the images you want me to organise?"
read -p "" whereVar
#finds oldest photo and puts its creation year in $dateVar
dateVar=`date '+%Y'`
for ext in jpg png jpeg bmp gif mov mp4 tif
do
	temp=$(find $whereVar -iname \*.$ext -type f -printf '%T+ %p\n' | sort | head -n 1)
	temp=${temp::4}
	if [ -n "$temp" ]
	then
		if [ "$temp" -lt "$dateVar" ]
		then
			dateVar=$temp
		fi
	fi
done
echo "the oldest file is from $dateVar"
echo ""
}

#method in which you choose if you want your organised files in default folder or somewhere else
#it creates dirs
#NEEDS PHOTOS() FUNCTION it actually could be just one function
photosInOrder () {
whereToVar="${HOME}/Documents/Date_Ordered_Images"
echo "Do you want to put your photos in the default folder"
echo "(${HOME}/Documents/Date_Ordered_Images)?"
read -p "y/n ? " testIt
case $testIt in
	"y") mkdir -p $whereToVar ;;
	"n") read -p "Give your own location: " location
		echo "Creating new folder at: $location/Date_Ordered_Images"
		mkdir -p "$location/Date_Ordered_Images"
		whereToVar="$location/Date_Ordered_Images" ;;
	*) echo "something went wrong"
esac
#loop creating folders year by year from oldest file yr to present yr
getYear=`date '+%Y'`
for ((i=$(($dateVar)); i<=$((getYear)); i++)); do
	for j in 01 02 03 04 05 06 07 08 09 10 11 12
	do
		mkdir -p "$whereToVar/$i/$j"
		echo "new dir created at $whereToVar/$i/$j"
	done
done
#now copy files from selected dir to destination in order
for ext in jpg png jpeg bmp gif tif
do
#nested loops for coping files based on year and month
	for ((i=$(($dateVar)); i<=$((getYear)); i++)); do
		for j in 01 02 03 04 05 06 07 08 09 10 11 12
		do
			if [ "$j" = "01" ] || [ "$j" = "03" ] || [ "$j" = "05" ] || [ "$j" = "07" ] || [ "$j" = "08" ] || [ "$j" = "10" ] || [ "$j" = "12" ]; then
				dateStart="$i-$j-01"
				dateStop="$i-$j-31"
			elif [ $(( $dateVar % 4 )) -eq 0 ] && [ "$j" = "02" ]; then
				dateStart="$i-$j-01"
				dateStop="$i-$j-29"
			elif [ "$j" = "02" ]; then
				dateStart="$i-$j-01"
				dateStop="$i-$j-28"
			else
				dateStart="$i-$j-01"
				dateStop="$i-$j-30"
			fi
		find $whereVar -iname \*.$ext -type f -newermt "$dateStart" ! -newermt "$dateStop" -exec cp {} "$whereToVar/$i/$j" \;
		done
	done
done
#if some of created directories are empty this is going to delete it 
find "$whereToVar" -type d -empty -delete
echo "DONE!"
}
photos
photosInOrder
