#!/bin/bash

k=false;					# keep
start_time=00:00:10;

# Option handling
while getopts t:k opts
do	case "$opts" in
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
title=`youtube-dl --no-warnings -e $link`;

# Check if a file with that name exists
if [ -f "$title".mp3 ]; then
	echo "$0": File "$title".mp3 already exists.;
	echo "$0": Cannot overwrite. Exiting...;
	exit;
fi

# Download video, and extract audio using youtube-dl tool
youtube-dl -f webm -x --audio-format mp3 -o '%(title)s0.%(ext)s' -k $link;

# Get the image to be used as album art
ffmpeg -i "$title"0.webm -ss $start_time -vframes 1 "$title.jpg";

# Put the image as album art
lame --ti "$title.jpg" --noreplaygain "$title"0.mp3 "$title.mp3";

# Remove temp files if 'k' flag is not set
if [ $k = false ]; then
	rm "$title"0.mp3 "$title"0.webm "$title.jpg";
fi;
