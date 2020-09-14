# define functions to be sourced

# source variables
source "./vars.sh"

# define functions for traps
exit_on_sig_SIGTERM () {
    # this function calls a helper script to find and kill child processes that
    # may have been started by this script, and exits, upon receiving the
    # SIGTERM signal

	echo "Script terminated" 2>&1
	exit 0
}

# create logger functions  
logger_args () {
    # this function send arguments to stdout and appends them to a logfile
	local LOGFILE
	LOGFILE="${DIR}/${BASENAME_S}.log"
	echo -e "$@" | tee -a $LOGFILE

    return
}

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
