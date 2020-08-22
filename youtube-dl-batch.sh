#!/bin/bash

#define the directory containing this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#source init file with user specific settings
source $DIR/init

#log info
echo "START_LOGFILE"
date && echo ""
echo "Running $0"
echo "Path is by default to: $PATH"
echo "Using $(which youtube-dl)"
echo "The system python, before modifying PATH, is $(which python)"

#set PATH in order to use pyenv, not system python
export PATH=~/.pyenv/shims:~/.pyenv/bin:"$PATH"
echo "PATH is now set to: $PATH"
echo "Now using the following python: $(which python)"

#define local batch file variables
AUDIO_DIR="$DIR/batch/audio"
VIDEO_DIR="$DIR/batch/video"
ALBUM_DIR="$DIR/batch/album"
SERIES_DIR="$DIR/batch/series"

AUDIO_BATCH_FILE="$AUDIO_DIR/audio.batch"
VIDEO_BATCH_FILE="$VIDEO_DIR/video.batch"
ALBUM_BATCH_FILE="$ALBUM_DIR/album.batch"
SERIES_BATCH_FILE="$SERIES_DIR/series.batch"

#define directories for static playlist download configuration
STATIC_PLAYLIST_AUDIO_DIR="$DIR/static_playlists/audio"
STATIC_PLAYLIST_VIDEO_DIR="$DIR/static_playlists/video"

#define archive file
ARCHIVE_FILE="$DIR/archive"

#check to see if the file "archive" exists and create it if it doesn't
if [ ! -f $ARCHIVE_FILE ]; then
       echo 'Creating archive file..."' && touch $ARCHIVE_FILE
fi

#copy the archive file to diff it later if useful
cp $ARCHIVE_FILE "$ARCHIVE_FILE.b" 

#cd to download directory
cd $DOWNLOAD_DIR

#Download Audio from batch files
youtube-dl --download-archive $ARCHIVE_FILE --config-location $AUDIO_DIR/audio.options --batch-file $AUDIO_BATCH_FILE

#Download Video from batch files
youtube-dl --download-archive $ARCHIVE_FILE --config-location $VIDEO_DIR/video.options --batch-file $VIDEO_BATCH_FILE

#Download albums as audio from batch files
youtube-dl --download-archive $ARCHIVE_FILE --config-location $ALBUM_DIR/album.options --batch-file $ALBUM_BATCH_FILE

#Download series as video from batch files
youtube-dl --download-archive $ARCHIVE_FILE --config-location $SERIES_DIR/series.options --batch-file $SERIES_BATCH_FILE

#static playlists

#audio
youtube-dl --download-archive $ARCHIVE_FILE --config-location $STATIC_PLAYLIST_AUDIO_DIR/audio.options $STATIC_PLAYLIST_AUDIO_URL

#video
youtube-dl --download-archive $ARCHIVE_FILE --config-location $STATIC_PLAYLIST_VIDEO_DIR/video.options $STATIC_PLAYLIST_VIDEO_URL

