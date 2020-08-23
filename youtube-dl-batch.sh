#!/bin/bash

#define the directory containing this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#set PATH in order to use pyenv, not system python
export PATH=~/.pyenv/shims:~/.pyenv/bin:"$PATH"

#source init file with user specific settings as variables
INIT_FILENAME="youtube-dl-batch.init"
source $DIR/$INIT_FILENAME

#define a temporary directory for storing joined config files
TMP_DIR="${DIR}/tmp"

#logger info
main_logger () {
	#basic logging info
	echo -e "START_LOGFILE\n"
	date
	#log pid to a file
	echo -e "Running $0 with process id $$\n"
	echo -e $$ > "${TMP_DIR}/${0}.pid"
	return
}

path_logger () {
	#path and program info
	echo -e "PATH is set to: $PATH\n"
	echo -e "Using the following python:\n$(which python)\n"
	echo -e "Using $(which youtube-dl)\n"
	return
}

config_joiner () {
	#takes 1 or more config files and joins them into one
	#used for joining a base config file with directory specific config 
	cat "$@"
	return
}

#generate logs for this session
main_logger
path_logger

#define archive file
ARCHIVE_FILE="${DIR}/archive"

#check to see if the file "archive" exists and create it if it doesn't
if [ ! -f $ARCHIVE_FILE ]; then
       echo -e "Creating archive file...\n" && touch $ARCHIVE_FILE
fi

#copy the archive file to diff it later if useful
cp $ARCHIVE_FILE "${ARCHIVE_FILE}.b" 

#define batch directory
BATCH_DIR="${DIR}/batch"

#cd to download directory
cd $DOWNLOAD_DIR

#define paths and download media
BASE_CONFIG_PATH="${DIR}/config/base_config"
CONFIG_BASENAME="config"
BATCH_BASENAME="batch"

for i in $(ls -1 "$BATCH_DIR"); do
	#join the base and current config files and write to the tmp directory
	CURRENT_DIR="${BATCH_DIR}/${i}"
	CURRENT_CONFIG_PATH="${CURRENT_DIR}/${CONFIG_BASENAME}"
	#JOINED_CONFIG="$(config_joiner $BASE_CONFIG_PATH $CURRENT_CONFIG_PATH)"
	TMP_CONFIG_FILE_PATH="${TMP_DIR}/${i}_config.tmp"
	#echo -e $JOINED_CONFIG > "$TMP_CONFIG_FILE_PATH" 
	#try not using a variable for the config joining, instead redirecting to a file directly
	config_joiner "$BASE_CONFIG_PATH" "$CURRENT_CONFIG_PATH" > "$TMP_CONFIG_FILE_PATH"
	echo -e "Joined config file contents are:\n\n"
	cat $TMP_CONFIG_FILE_PATH
	echo -e "\n\n"
	echo -e "The config file contains $(wc -l "$TMP_CONFIG_FILE_PATH") lines\n" 

	#define the path of the batch file containing urls to be downloaded
	BATCH_FILE_PATH="${CURRENT_DIR}/${BATCH_BASENAME}"
	echo -e "DEBUG: Batch file path is: $BATCH_FILE_PATH\n"
	echo -e "DEBUG: Batch file contents' tail is:\n"
	tail $BATCH_FILE_PATH

	#download the media
	echo -e "Downloading media from $CURRENT_DIR\n" 
	#use line continuation to make syntax clear
	youtube-dl \
		--download-archive "$ARCHIVE_FILE" \
		--config-location "$TMP_CONFIG_FILE_PATH" \
		--batch-file "$BATCH_FILE_PATH"
	#report
	echo -e "Finished downloading media from $CURRENT_DIR\n" 
done
