# file containing variables to be sourced

# this variable will give the absolute path of the script that sources it,
# regardless of where the file containing this variable declaration is
# located
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# define the directory containing the sourcing script
DIR="$(dirname $SCRIPTPATH)"

# the name of the sourcing script, without a .sh suffix; useful for creating
# logging filenames
BASENAME="$(basename -s ".sh" $0)"

# the configuration directory's absolute path
CONFIG_DIR="${DIR}/config"

# define the path to the base config file, which is applied to all
# downloads 
BASE_CONFIG_PATH="${CONFIG_DIR}/base_config"

# define the generic base filenames for config files and batch files in each
# download directory
CONFIG_BASENAME="config"
BATCH_BASENAME="batch"

# the tmp directory's absolute path
TMP_DIR="${DIR}/tmp"

# the batch directory's absolute path
BATCH_DIR="${DIR}/batch"

# the script directory's absolute path
DIR="${DIR}/scripts"

# the location where media will be downloaded
DOWNLOAD_DIR="$HOME/Music/youtube-dl/batch"

# define archive file
ARCHIVE_FILE="${DIR}/archive"
