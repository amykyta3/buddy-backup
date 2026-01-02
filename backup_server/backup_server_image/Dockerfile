FROM debian:stable-slim

# Install SSH server, and some other useful utilities
RUN apt update
RUN apt -y install openssh-server less nano openssl rsync
RUN apt clean

# Disable the ssh command for non-root users
RUN chmod g-rwx,o-rwx $(which ssh)

# Change welcome banner on login
RUN chmod -x /etc/update-motd.d/*
RUN echo "Welcome to the backup server!" > /etc/motd

# Patch SSH server settings
# First, delete any existing settings that will be overridden
RUN sed -i '/^PasswordAuthentication/d' /etc/ssh/sshd_config
RUN sed -i '/^AllowTcpForwarding/d' /etc/ssh/sshd_config
RUN sed -i '/^X11Forwarding/d' /etc/ssh/sshd_config
RUN sed -i '/^PermitRootLogin/d' /etc/ssh/sshd_config
RUN sed -i '/^LoginGraceTime/d' /etc/ssh/sshd_config
RUN sed -i '/^ClientAliveInterval/d' /etc/ssh/sshd_config
RUN sed -i '/^HostKey/d' /etc/ssh/sshd_config
# Append desired settings
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
RUN echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
RUN echo "X11Forwarding no" >> /etc/ssh/sshd_config
RUN echo "PermitRootLogin no" >> /etc/ssh/sshd_config
RUN echo "LoginGraceTime 30" >> /etc/ssh/sshd_config
RUN echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
RUN echo "HostKey /etc/ssh/host_keys/ssh_host_rsa_key" >> /etc/ssh/sshd_config
RUN echo "HostKey /etc/ssh/host_keys/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config
RUN echo "HostKey /etc/ssh/host_keys/ssh_host_ed25519_key" >> /etc/ssh/sshd_config

EXPOSE 22

ADD launcher.sh /
RUN chmod g-rwx,o-rwx /launcher.sh
CMD /launcher.sh
