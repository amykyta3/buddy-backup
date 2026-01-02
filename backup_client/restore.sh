#!/bin/bash

#-------------------------------------------------------------------------------
# Parse args
#-------------------------------------------------------------------------------
print_usage () {
    echo "Usage:"
    echo "  $0 [options] PATH_TO_RESTORE  OUTPUT_DIR"
    echo ""
    echo "Required arguments:"
    echo "  PATH_TO_RESTORE:  Absolute path of the file or folder you want to restore."
    echo "  OUTPUT_DIR:       Path to a new folder where the restored files will be copied."
    echo "                    Parent folder must be writable, and have enough space to"
    echo "                    temporarily store 2 copies of the data."
    echo ""
    echo "Optional arguments:"
    echo "  -k KEY, --master-key KEY"
    echo "                    Use the master key for decryption instead."
    echo "                    This should only be used if your 'gocryptfs.conf' file was"
    echo "                    was lost, or you no longer have your decryption password"
}

MASTER_KEY=""
ARGS=$(getopt -n $0 -o hk: -l help,master-key: -- "$@")
if [[ $? -ne 0 ]]; then
    print_usage
    exit 1
fi
eval set -- "$ARGS"
while true; do
  case "$1" in
    -h | --help)
        print_usage
        exit 0
        ;;
    -k | --master-key)
        echo "info: Using master key instead of password in backup.conf"
        MASTER_KEY=$2
        shift 2
        ;;
    --) shift;
        break
        ;;
  esac
done
if [[ $# -ne 2 ]]; then
    echo "error: Incorrect number of arguments"
    echo ""
    print_usage
    exit 1
fi
PATH_TO_RESTORE=$1
OUTPUT_DIR=$(realpath $2)

#-------------------------------------------------------------------------------
# Check args
#-------------------------------------------------------------------------------
if [[ ! $PATH_TO_RESTORE = /* ]]; then
    echo "error: Path to restore must be absolute, not relative"
    exit 1
fi

OUTPUT_DIR_TMP=${OUTPUT_DIR}.encrypted
parent_dir=$(dirname $OUTPUT_DIR)
if [[ ! -w $parent_dir ]]; then
    echo "error: Output path is not writable: $parent_dir"
    exit 1
fi

#-------------------------------------------------------------------------------
set -e
cd "$( dirname -- "${BASH_SOURCE[0]}" )"
source common.sh

cleanup2 () {
    cleanup
    rm -rf $OUTPUT_DIR_TMP
}

# Cleanup if aborted by user
trap "cleanup2; echo 'aborted'; exit 1;" SIGINT SIGTERM

check_tools_installed
init_config

if [[ (! -f "$gocryptfs_conf_path") && (-z $MASTER_KEY) ]]; then
    echo "error: '$gocryptfs_conf_path' is missing."
    echo "If you lost this file, your only hope for restoring is to use the --master-key flag."
    cleanup2
    exit 1
fi

# Set up output dirs
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR_TMP

# Copy encrypted files from remote server
echo "---------------------------------------------------------------------"
echo "Copying encrypted backup files from '$server_hostname'"
echo "---------------------------------------------------------------------"
src=${server_login}@${server_hostname}:backup/.${PATH_TO_RESTORE}
dst=${OUTPUT_DIR_TMP}
set +e
rsync -av --progress --relative -e "ssh -p $server_port" $src $dst
if [[ $? -ne 0 ]]; then
    echo "error: rsync failed"
    cleanup2
    exit 1
fi
set -e

# Mount decrypted view of the restored files
mkdir -p .tmp/mnt
if [[ ! -z $MASTER_KEY ]]; then
    gocryptfs \
        $COMMON_GOCRYPTFS_ARGS \
        -ro \
        -masterkey $MASTER_KEY \
        $OUTPUT_DIR_TMP .tmp/mnt
else
    gocryptfs \
        $COMMON_GOCRYPTFS_ARGS \
        -ro \
        -passfile .tmp/encryption_password \
        -config $gocryptfs_conf_path \
        $OUTPUT_DIR_TMP .tmp/mnt
fi

# Copy decrypted files to output dir
echo "---------------------------------------------------------------------"
echo "Decrypting files..."
echo "---------------------------------------------------------------------"
set +e
rsync -av --progress .tmp/mnt/ $OUTPUT_DIR
if [[ $? -ne 0 ]]; then
    echo "error: rsync failed"
    cleanup2
    exit 1
fi
set -e

# Unmount folder
fusermount -q -u .tmp/mnt

cleanup2

echo "Restore complete!"
