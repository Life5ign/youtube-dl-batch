# file containing variables to be sourced

# this variable will give the absolute path of the script that sources it,
# regardless of where the file containing this variable declaration is
# located
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# define the directory containing the sourcing script
SCRIPT_DIR="$(dirname $SCRIPTPATH)"

# the name of the sourcing script, without a .sh suffix; useful for creating
# logging filenames
BASENAME="$(basename -s ".sh" $0)"

# the configuration directory's absolute path
CONFIG_DIR="${SCRIPT_DIR}/config"

# the tmp directory's absolute path
TMP_DIR="${SCRIPT_DIR}/tmp"

# the batch directory's absolute path
BATCH_DIR="${SCRIPT_DIR}/batch"

# the script directory's absolute path
SCRIPT_DIR="${SCRIPT_DIR}/scripts"

# the location where media will be downloaded
DOWNLOAD_DIR="$HOME/Music/youtube-dl/batch"
