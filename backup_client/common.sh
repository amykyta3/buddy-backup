check_tools_installed () {
    if [[ -z $(which rsync) ]]; then
        echo "error: rsync is not installed"
        exit 1
    fi

    if [[ -z $(which gocryptfs) ]]; then
        echo "error: gocryptfs is not installed"
        exit 1
    fi
}

init_config () {
    if [[ ! -f backup.conf ]]; then
        echo "error: 'backup.conf' is missing!"
        echo "Create it using 'backup.conf.TEMPLATE' as a starting point"
        exit 1
    fi

    # Set defaults
    server_port=22
    gocryptfs_conf_path=gocryptfs.conf
    rsync_max_retry=5

    # Load user settings
    source backup.conf

    # Write the password to a file so that it can be passed to gocryptfs
    mkdir -p .tmp
    echo $encryption_password > .tmp/encryption_password
}

cleanup () {
    set +e
    fusermount -q -u .tmp/mnt

    rm -rf .tmp
    set -e
}

# Some common args to use for all calls to gocryptfs
# gocryptfs is finicky - some settings are encoded in the gocryptfs.conf, and
# some others aren't. For consistency, provide them via command line, even if
# it is redundant.
#
#   -plaintextnames
#       Do not encrypt filenames. Makes it easier to explore the backups & debug
#   -one-file-system
#       Do not traverse mountpoint boundaries
#   -aessiv
#       Force AES-SIV. This is required when restoring using a master key since
#       gocryptfs is not symmetrical when running init vs master key
COMMON_GOCRYPTFS_ARGS="-plaintextnames -one-file-system -aessiv"
