#!/bin/bash

# source variables
source "./vars.sh"

# if the system is using pyenv, set PATH in order to use pyenv, not system
# python
if [ -d "${HOME}/.pyenv" ]; then
    export PATH=~/.pyenv/shims:~/.pyenv/bin:"$PATH"
fi

# source init file with user specific settings as variables

# define functions for traps
exit_on_sig_SIGTERM () {
    # this function calls a helper script to find and kill child processes that
    # may have been started by this script, and exits, upon receiving the
    # SIGTERM signal

	echo "Script terminated" 2>&1
	exit 0
}

# trap this script
trap exit_on_sig_SIGTERM SIGTERM

# create logger functions that send arguments to stdout and append them
# to a logfile 
logger_args () {
	local LOGFILE
	LOGFILE="${DIR}/${BASENAME}.log"
	echo -e "$@" | tee -a $LOGFILE
}

# logger info
main_logger () {
	# basic logging info
	echo -e "START_LOGFILE\n"
	date
	# log pid to a file
	echo -e "Running $0 with process id $$\n"
	echo -e $$ > "${TMP_DIR}/${BASENAME}.pid"
	return
}

path_logger () {
	# path and program info
	echo -e "PATH is set to: $PATH\n"
	echo -e "Using the following python:\n$(which python)\n"
	echo -e "Pyenv is using the following python and version: \
        \n$(pyenv which python)\n"
	echo -e "Using the following youtube-dl:\n$(which youtube-dl)\n"
	return
}

config_joiner () {
    # takes 1 or more (config) files as arguments and joins them into one
    # variable used for joining a base config file with directory specific
    # config 
	cat "$@"
	return
}

# generate logs for this session
main_logger
path_logger

# check to see if the file "archive" exists and create it if it doesn't
if [ ! -f $ARCHIVE_FILE ]; then
	echo -e "Creating archive file...\n" && touch $ARCHIVE_FILE
else
	echo -e "Found archive file: ${ARCHIVE_FILE}"
fi

# copy the archive file to diff it later if useful
cp $ARCHIVE_FILE "${ARCHIVE_FILE}.b" 

# cd to download directory
cd $DOWNLOAD_DIR

for i in $(ls -1 "$BATCH_DIR"); do
	# join the base and current config files and write to the tmp directory
	CURRENT_DIR="${BATCH_DIR}/${i}"

	# if there is a pause file in this directory, go to the next directory
	if [ -e "${CURRENT_DIR}/pause" ]; then
		echo -e "Found a file named "pause" in ${CURRENT_DIR} ; skipping \
            downloading media in this directory" 
		continue
	fi

	# otherwise, proceed with the download
	echo -e "Downloading content from ${CURRENT_DIR}...\n"

	# join the local config file with the global config file and define a
    # filename
    # TODO use mktemp and $$ to create random filename with the pid in it
	CURRENT_CONFIG_PATH="${CURRENT_DIR}/${CONFIG_BASENAME}"
	TMP_CONFIG_FILE_PATH="${TMP_DIR}/${i}_config.tmp"

    # join the base config with the current directory's config file, and
    # redirect to a temporary file
	config_joiner "$BASE_CONFIG_PATH" "$CURRENT_CONFIG_PATH" > \
        "$TMP_CONFIG_FILE_PATH"
	# echo -e "The joined config file contains $(wc -l \
    # "$TMP_CONFIG_FILE_PATH" | sed -E "s/(^ *)([0-9]+)(.*)/\2/g") lines\n" 

	# define the path of the batch file containing urls to be downloaded
	BATCH_FILE_PATH="${CURRENT_DIR}/${BATCH_BASENAME}"

	# download the media
	echo -e "\nDownloading media from $CURRENT_DIR\n" 

	# use line continuation to make syntax clear
	youtube-dl \
		--download-archive "$ARCHIVE_FILE" \
		--config-location "$TMP_CONFIG_FILE_PATH" \
		--batch-file "$BATCH_FILE_PATH"

	echo -e "Finished downloading media from $CURRENT_DIR\n" 
done
