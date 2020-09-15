#!/bin/bash -x
trap read DEBUG

# list processes that have a process group leader with the pid located in a
# file in the tmp directory, which is generated by the main srcipt and
# contains its pid

# source variables and functions using git rev-parse
source "$(git rev-parse --show-toplevel)/vars.sh"
source "$(git rev-parse --show-toplevel)/functions.sh"

# usage
usage () {
	echo "$(basename $0): usage: $(basename $0) [--kill] [--pid <pid> |
        --file <file>]"
	return
}

# process positional parameters using while, case, and shift
kill_ps=
pid_file=
pid_number=

while [[ -n $1 ]]; do
    case $1 in
        -p | --pid)     shift
                        pid_number=$1
                        ;;
        -f | --file)    shift
                        pid_file=$1
                        ;;
        -k | --kill)    kill_ps=1
                        ;;
        *)              usage >&2
                        exit 1
                        ;;
    esac
    shift
done

# generate logs for this session
main_logger
path_logger

#files to store ps info
CHILD_PROCESS_INFO_FILE="${TMP_DIR}/${BASENAME}.info"
CHILD_PROCESS_FILE="${TMP_DIR}/${BASENAME}.pid"

# if a single optional parameter was specified, representing a pid, use that as
# the group leading pid.  #otherwise, read a pid from a file
if [ "${1}" ]; then
    
echo -e "Using parameter ${1} as the group leading pid." >&2
	# TODO input validation
	GROUP_LEADER_PID="${1}"

# otherwise, check for existence of file containing the group leading pid, and
# if it exists, assign the pid to a variable 
elif [ -e "$pid_file" ]; then
echo -e "Found group leading pid file ${pid_file}\n" >&2
	GROUP_LEADER_PID=$(cat $pid_file | sed 's/ //g')
	echo -e "Got pid $GROUP_LEADER_PID from ${pid_file}\n" 
else
	echo -e "No pid supplied, and failed to locate group leading pid file \
        ${pid_file}\nExiting.\n" 
	exit 1
fi

# use the group leader pid to find processes with this pid as their group
# leader and write info about them to a file
if [ -n "$GROUP_LEADER_PID" ]; then
	echo -e "Found the following processes with group leader \
        ${GROUP_LEADER_PID}:\n"
	ps -cxf -o pid,gid,pgid,rgid,tpgid -g $GROUP_LEADER_PID \
        | tee $CHILD_PROCESS_INFO_FILE
	echo -e "Wrote info about these processes to \
        ${CHILD_PROCESS_INFO_FILE}...\n"
    # get the pids for these processes and write them to a file, one pid per
    # line, for use later
echo -e "Writing process ids to ${CHILD_PROCESS_FILE}\n" >&2
    # use sed to remove the header line from ps output and grab the pids in the
    # first column for all the remaining lines
	CHILD_PIDS="$(ps -x -o pid -g "$GROUP_LEADER_PID" \
        | sed -En -e '1! s/(^ *)([0-9]+)(.*)/\2/g p')"
	echo -e "$CHILD_PIDS" > $CHILD_PROCESS_FILE
	
else
	echo -e "There was no group leading pid in ${pid_file}\n" 
fi

# kill all processes

kill $(< "${CHILD_PROCESS_FILE}")
KILLSTATUS="$?"
if [[ "$KILLSTATUS" ]]; then
	echo "Successfully killed processes in ${CHILD_PROCESS_FILE}"
else
	echo -e "kill exited unsuccessfully with status ${KILLSTATUS}"
fi

# if specified, kill the group led processes and the main process
# if [ "$1" == "--kill" ]; then
# 	kill $(< "${CHILD_PROCESS_FILE}")
# 	KILLSTATUS="$?"
# 	if [[ "$KILLSTATUS" ]]; then
# 		echo "Successfully killed processes in ${CHILD_PROCESS_FILE}"
# 	else
# 		echo -e "kill exited unsuccessfully with status ${KILLSTATUS}."
# 	fi
# fi

