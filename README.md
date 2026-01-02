# Offsite Buddy-Backup!

This repo provides an implementation of an offsite "buddy-backup" system where:
* A friend hosts a backup **server** on their NAS where your backup data will be stored.
* You run a **client** script periodically that encrypts and copies your backup data to your friend's server.


## Design assumptions / requirements

* Backup data is encrypted client-side. Server only stores encrypted files.
* This implements the **1** in the "3-2-1" backup strategy. This is not intended
  for historical snapshots, but rather a last-ditch backup in case your house burns down.
  ie: use this to back up your duplicity snapshots.
* Requires key-based authentication for SSH
* SSH server is in a docker container to limit access to the rest of the system


## Set up guides

* [Server set up guide](docs/server.md)
* [Client set up guide](docs/client.md)
