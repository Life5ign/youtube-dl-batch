#!/bin/bash

#normalize audio in a multiplexed file
#usage:
#normalize.sh <filename>
#anzlyze the volume
ffmpeg -i $1 -af "volumedetect" -vn -sn -dn -f null /dev/null

#normalize using "loudnorm" filter
ffmpeg -i $1 -af "loudnorm" -c:v copy -c:a aac -b:a 192k  
