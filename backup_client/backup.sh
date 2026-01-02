#!/bin/bash
set -e
cd "$( dirname -- "${BASH_SOURCE[0]}" )"
source common.sh

# Cleanup if aborted by user
trap "cleanup; echo 'aborted'; exit 1;" SIGINT SIGTERM

check_tools_installed
init_config

if [[ ! -f $gocryptfs_conf_path ]]; then
    echo "error: '$gocryptfs_conf_path' is missing. Run './first_time_init.sh' first"
    cleanup
    exit 1
fi

for dir in $backup_dirs; do
    if [[ ! -d $dir ]]; then
        # Is not a folder, or it doesn't exist
        echo "warning: skipping invalid directory: $dir"
        continue
    fi
    # transform to absolute path, but preserve symlinks
    dir=$(realpath -m -s $dir)

    echo "---------------------------------------------------------------------"
    echo "Backing up: $dir"
    echo "---------------------------------------------------------------------"

    # Mount an encrypted view of the folder to be backed up
    mkdir -p .tmp/mnt
    gocryptfs \
        $COMMON_GOCRYPTFS_ARGS \
        -ro -reverse \
        -passfile .tmp/encryption_password \
        -config $gocryptfs_conf_path \
        $dir .tmp/mnt

    # copy files!
    src=.tmp/mnt/
    dst=${server_login}@${server_hostname}:backup${dir}
    attempt=0
    while ! rsync -avP --mkpath --delete -e "ssh -p $server_port" $src $dst; do
        attempt=$((attempt + 1))
        if [[ $attempt -ge $rsync_max_retry ]]; then
            echo "error: rsync failed"
            cleanup
            exit 1
        fi
        echo "warning: rsync failed. Retrying ..."
    done

    # Unmount folder
    fusermount -q -u .tmp/mnt
done

cleanup

echo "Backup complete!"
