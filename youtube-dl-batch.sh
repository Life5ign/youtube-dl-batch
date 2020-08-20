#!/bin/bash

#define the directory containing the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#source init file with user settings
source $DIR/init

#formatting, script name, and date for logging purposes
echo "START_LOGFILE"
date && echo ""
echo "Running $0"
echo "Path is by default to: $PATH"
echo "Using $(which youtube-dl)"
echo "The system python, before modifying PATH, is $(which python)"

#set PATH correctly in order to use pyenv, not system python
export PATH=~/.pyenv/shims:~/.pyenv/bin:"$PATH"
echo "PATH is now set to: $PATH"

#define local batch file variables
YOUTUBE_DL_AUDIO_BATCH_FILE="$DIR/audio.batch"
YOUTUBE_DL_VIDEO_BATCH_FILE="$DIR/video.batch"
YOUTUBE_DL_PLAYLIST_BATCH_FILE="$DIR/playlist.batch"
YOUTUBE_DL_PLAYLIST_ARCHIVE_FILE="$DIR/archive"

#cd to download directory
cd $YOUTUBE_DL_DOWNLOAD_DIR

#Download Audio from batch files
#comment out completed URLs in the batch file
youtube-dl --no-progress --extract-audio --audio-format mp3 --batch-file $YOUTUBE_DL_AUDIO_BATCH_FILE --no-overwrites --restrict-filenames && sed -E -i '' 's/(^[^#])/#&/' $YOUTUBE_DL_AUDIO_BATCH_FILE

#Download Video from batch files
#comment out completed URLs in the batch file
youtube-dl --no-progress --batch-file $YOUTUBE_DL_VIDEO_BATCH_FILE --no-overwrites --restrict-filenames && sed -E -i '' 's/(^[^#])/#&/' $YOUTUBE_DL_VIDEO_BATCH_FILE

#Download Playlists as audio from batch files
youtube-dl --no-progress --yes-playlist --extract-audio --audio-format mp3 --batch-file $YOUTUBE_DL_PLAYLIST_BATCH_FILE --output "./%(playlist_title)s/%(playlist_index)s-%(title)s.%(ext)s" --no-overwrites --restrict-filenames --sleep-interval 5 --max-sleep-interval 10 && sed -E -i '' 's/(^[^#])/#&/' $YOUTUBE_DL_PLAYLIST_BATCH_FILE

#Download items from my channel's "audio" and "video" playlists, as audio and video respectively, using a local archive file to prevent re-downloading items that remain in the playlists.

#check to see if the file "archive" exists and create it if it doesn't
if [ ! -f $DIR/archive ]; then
       echo 'Creating regular file "archive..."' && touch $DIR/archive
fi

#First, copy the archive file to diff it later if useful
cp $DIR/archive $DIR/archive.b

#audio
youtube-dl --verbose --no-progress --yes-playlist --extract-audio --audio-format mp3 --no-overwrites --restrict-filenames --download-archive $YOUTUBE_DL_PLAYLIST_ARCHIVE_FILE --output "./%(uploader)s/%(title)s-%(id)s.%(ext)s" --sleep-interval 5 --max-sleep-interval 10 $CHANNEL_AUDIO_PLAYLIST

#video
youtube-dl --merge-output-format mkv --verbose --no-progress --retries "infinite" --fragment-retries "infinite" --yes-playlist --no-overwrites --restrict-filenames --download-archive $YOUTUBE_DL_PLAYLIST_ARCHIVE_FILE --output "./%(uploader)s/%(title)s-%(id)s.%(ext)s" --sleep-interval 5 --max-sleep-interval 10 $CHANNEL_VIDEO_PLAYLIST

