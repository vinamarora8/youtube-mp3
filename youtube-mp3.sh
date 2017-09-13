#!/bin/bash

k=false;					# keep
start_time=00:00:10;

# Option handling
while getopts t:k o
do	case "$o" in
	t)		if [[ $OPTARG =~ ^[0-9]+$ ]]; then 		# validity of argument
				start_time=00:00:$OPTARG;
			else
				echo "$0": Invalid argument for option -t. Use only numbers;
				exit;
			fi;;

	k)		k=true;;

	[?])	echo "$0": Try again with valid options;
			exit;;
	esac
done

# Get video name
link=${!OPTIND}
A=`youtube-dl --no-warnings -e $link`;

# Check if a file with that name exists
if [ -f $A ]; then
	echo "$0": "$A".mp3 already exists. Cannot overwrite. Exiting...;

# Download video, and extract audio using youtube-dl tool
youtube-dl -f webm -x --audio-format mp3 -o '%(title)s0.%(ext)s' -k $link;

# Get the image to be used as album art
ffmpeg -i "$A"0.webm -ss $start_time -vframes 1 "$A.jpg";

# Put the image as album art
lame --ti "$A.jpg" --noreplaygain "$A"0.mp3 "$A.mp3";

# Remove temp files if 'k' flag is not set
if [ $k = false ]; then
	rm "$A"0.mp3 "$A"0.webm "$A.jpg";
fi;
