# file containing variables to be sourced

# define the project root directory, which is determined by the output of a git
# rev-parse command
PROJECT_ROOT_DIR="$(git rev-parse --show-toplevel)"

# define the directory of any script that sources this file.  NOTE: this will
# change based on the directory that this script is located in.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# define the basename of the script that sources this file, without removing
# any suffix
BASENAME="$(basename $0)"

# define the absolute path of the script that sources this file
SCRIPTPATH="${DIR}/${BASENAME}"

# the name of the sourcing script, without a .sh suffix; useful for creating
# logging filenames
BASENAME_S="$(basename -s ".sh" $0)"

# the configuration directory's absolute path
CONFIG_DIR="${PROJECT_ROOT_DIR}/config"

# define the path to the base config file, which is applied to all
# downloads 
BASE_CONFIG_PATH="${CONFIG_DIR}/base_config"

# define the generic base filenames for config files and batch files in each
# download directory
CONFIG_BASENAME="config"
BATCH_BASENAME="batch"

# the tmp directory's absolute path
TMP_DIR="${PROJECT_ROOT_DIR}/tmp"

# the batch directory's absolute path
BATCH_DIR="${PROJECT_ROOT_DIR}/batch"

# the script directory's absolute path
SCRIPT_DIR="${PROJECT_ROOT_DIR}/scripts"

# the location where media will be downloaded
DOWNLOAD_DIR="${HOME}/Music/youtube-dl/batch"

# define archive file
ARCHIVE_FILE="${PROJECT_ROOT_DIR}/archive"
