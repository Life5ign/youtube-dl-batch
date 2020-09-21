youtube-dl-batch - a youtube-dl wrapper that downloads multiple batch files,
each with specific config options, avoiding duplicate downloads

- [INSTALLATION] #installation
- [DESCRIPTION & USAGE] #"description & usage"
- [CONFIGURATION] #configuration

# INSTALLATION

To install `youtube-dl-batch`, `cd` to your desired directory and run:

    git clone
    chmod +x youtube-dl-batch.sh

# DESCRIPTION & USAGE

For those familiar with `youtube-dl`, `youtube-dl-batch` is essentially an
automated mapping between batch files and config files, with a global download
archive to prevent duplicate downloads.

`youtube-dl-batch` examines each user-defined directory in the project's
`batch` directory.  For each subdirectory of `batch`, it then downloads media
from the urls in the `batch` file, with the options specified in the `config`
file.  In addition, `youtube-dl-batch` reads and updates a project-wide archive
file with the IDs of all previously downloaded media, in order to prevent
re-downloading the same content.  This is equivalent to running `youtube-dl`
with the `--batch-file`, `--config-location` and `--download-archive` options
for each user-defined directory.

If a file named `pause` is found within a user-defined directory, downloads
from this directory are skipped until this file is removed.

Note that user-defined directories can have any name, and are parsed lexically
by the shell.  The `batch`, `config`, and `pause` files should not be renamed,
however.

`youtube-dl-batch` was written so that it could be called in a cron job during
certain hours of the day when data from a satellite ISP doesn't count toward a
monthly billed quota (oftentimes in the vicinity of 02:00 to 08:00 every day).
Do not add this to your root crontab; only add it to your user crontab.

# CONFIGURATION

In addition to the `youtube-dl` options specified in each `config` file,
`youtube-dl-batch` also reads a project-wide config file `config/base_config`,
which specifies options that are applied to all downloads.  This is included so
that the user doesn't have to add these options to each new `config` file in
the `batch` subdirectories.

By default, `youtube-dl-batch` downloads media to the location specified in
`vars.sh`, creating this directory if it doesn't exist.


