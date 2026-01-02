#!/bin/bash

# Stash host keys to persistent volume so they can be re-used
mkdir -p /etc/ssh/host_keys
cp -n /etc/ssh/ssh_host_*_key /etc/ssh/host_keys/

# To simplify setup, users are defined based on which directories exist in the
# /home volume
# Loop through each folder found and ensure the user exists and is set up correctly
for usr in $(ls -1 /home/)
do
    if id "$usr" >/dev/null 2>&1; then
        echo "User '$usr' already exists"
    else
        echo "Creating user '$usr'"
        # Add user with random password
        useradd \
            --no-create-home \
            --home-dir /home/$usr \
            --shell $(which bash) \
            --password "$(openssl passwd -1 $(openssl rand -base64 30))" \
            $usr
    fi

    # Fixup permissions of user folders
    # Since /home is a docker volume that could be manipulated by the host,
    # it is possible that permissions could get mangled by the host
    chown -R $usr /home/$usr
    chgrp -R $usr /home/$usr
    chmod 700 /home/$usr
    chmod 700 /home/$usr/.ssh
    chmod 600 /home/$usr/.ssh/authorized_keys
done

# Start SSH server
/usr/sbin/sshd -D -e
