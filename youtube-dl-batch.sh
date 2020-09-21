#!/bin/bash

# define the directory containing this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# source variables
source "${DIR}/vars.sh"

# if the system is using pyenv, set PATH in order to use pyenv, not system
# python
if [ -d "${HOME}/.pyenv" ]; then
    export PATH=~/.pyenv/shims:~/.pyenv/bin:"$PATH"
fi

# create logger functions  
logger_args () {
    # this function send arguments to stdout and appends them to a logfile
	local LOGFILE
    # by default, we set this logger to write to a file that is located in the
    # same directory as the script that sources this functions definition file
	LOGFILE="${DIR}/${BASENAME_S}.log"
	echo -e "$@" | tee -a $LOGFILE

    return
}

main_logger () {
	# basic logging info
	echo -e "START_LOGFILE\n"
	date
    echo -e "Running $0 with process id $$\n"
    # log pid to a file
    PID_FILE="$(mktemp "${TMP_DIR}/${BASENAME_S}.$$.XXXXXXXXXX")"
    echo -e $$ > $PID_FILE

	return
}

path_logger () {
	# log path and program info
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

# define functions for traps
trap_handle () {
    # clean up upon receiving SIGTERM or SIGINT
    echo -e "Caught signal SIGTERM or SIGINT"
    if [[ "$child" ]]; then
        echo -e "Killing child process\n$(ps -o pid,comm $child)\nwith pid
        $child"
        kill -TERM $child
    fi
    
    echo -e "${BASENAME}:\n$(date)\nExiting"
	exit 0

    return
}

# trap SIGINT and SIGTERM for this script
trap trap_handle INT TERM

# check to see if the file "archive" exists and create it if it doesn't
if [ ! -f $ARCHIVE_FILE ]; then
	echo -e "Creating archive file...\n" && touch $ARCHIVE_FILE
else
	echo -e "Found archive file: ${ARCHIVE_FILE}"
fi

# copy the archive file to diff it later if useful
cp $ARCHIVE_FILE "${ARCHIVE_FILE}.b" 

# cd to download directory
if [[ -d "$DOWNLOAD_DIR" ]] && cd $DOWNLOAD_DIR; then
    echo "Changed directory to $DOWNLOAD_DIR"
else
    echo "Couldn't cd to ${DOWNLOAD_DIR}. Exiting."
    exit 1
fi

# download media
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

	# execute youtube-dl in the background with the specified parameters 
	youtube-dl \
		--download-archive "$ARCHIVE_FILE" \
		--config-location "$TMP_CONFIG_FILE_PATH" \
		--batch-file "$BATCH_FILE_PATH" \
        &

    # wait for this process so that the main script can catch SIGTERM or SIGINT
    # and run the corresponding trap. We don't want to "exec" youtube-dl, since
    # we need to keep the shell around to continue with the loop. There are
    # likely some race conditions created here, so this approach could be
    # improved upon.
    child=$!
    wait $child

    # Log the success or failure of the last waited-for background command.
    # wait, as called above, will exit with the exit status of the specified
    # pid
    wait_exit_status=$?
    if [[ $wait_exit_status -gt 0 ]]; then
        echo "There was an error: process $child exited with
        status $wait_exit_status" 
    else
	    echo -e "Finished downloading media from $CURRENT_DIR\n" 
    fi
done
