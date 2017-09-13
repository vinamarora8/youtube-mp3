#!/bin/bash

k=false;					# keep
o=false;					# output filename
f=false;					# force output_filename

start_time=00:00:10;

# Option handling
while getopts t:o:kf opts
do	case "$opts" in
	t)		if [[ $OPTARG =~ ^[0-9]+$ ]]; then 		# validity of argument
				start_time=00:00:$OPTARG;
			else
				echo "$0": Invalid argument for option -t. Use only numbers;
				exit;
			fi;;

	k)		k=true;;

	o)		o=true;
			output_filename=$OPTARG;;

	f)		f=true;;

	[?])	echo "$0": Try again with valid options;
			exit;;
	esac
done

# Get video name
link=${!OPTIND}
title=`youtube-dl --no-warnings -e $link`;

# Check if a file with that name exists
if [ -f "$title".mp3 ] && ! $f; then
	echo "$0": File "$title".mp3 already exists.;
	echo "$0": Cannot overwrite. Exiting...;
	exit 1;
fi

# Download video, and extract audio using youtube-dl tool
youtube-dl -f webm -x --audio-format mp3 -o '%(title)s0.%(ext)s' -k $link;

# Get the image to be used as album art
ffmpeg -i "$title"0.webm -ss $start_time -vframes 1 "$title.jpg";

# Put the image as album art
lame --ti "$title.jpg" --noreplaygain "$title"0.mp3 "$title.mp3";

# Remove temp files if 'k' flag is not set
if ! $k ; then
	echo $0": Removing temporary files";
	rm "$title"0.mp3 "$title"0.webm "$title.jpg";
fi;

# Rename the output file to output_filename
if $o ; then
	echo $0": Renaming file to "$output_filename;
fi

mv -f "$title".mp3 "$output_filename";

exit 0;
