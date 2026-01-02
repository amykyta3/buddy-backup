#!/bin/bash
set -e
cd "$( dirname -- "${BASH_SOURCE[0]}" )"
source common.sh

check_tools_installed
init_config

# Run init
gocryptfs \
    $COMMON_GOCRYPTFS_ARGS \
    -init --reverse \
    -config $gocryptfs_conf_path \
    -passfile .tmp/encryption_password \
    .

cleanup
