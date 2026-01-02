# Setting up the backup server

This is where *someone else* (your backup buddy) will store **their** files.


## 0. Requirements

This assumes you already solved the following prerequisites:
* Your NAS has Docker Compose installed
* Your home's WAN IP is static, and/or is mapped to a domain name that is accessible externally.

## 1. Create user data folders for your backup buddy
This is where your backup buddy will store their data.

For example, if you have two backup buddies "alice" and "bob":
```bash
mkdir -p /my_storage/remote_backup_data/alice
mkdir -p /my_storage/remote_backup_data/bob
```

* The path `/my_storage/remote_backup_data` would be the value for the env variable `BACKUP_DATA_HOMEDIR` later.
* The server container will automatically create login users `alice` and `bob`.


## 2. Set up login credentials

* Get an SSH *public* key from your backup partner
* Paste this into a file called `authorized_keys` in the appropriate user directory.

  For example: `/my_storage/remote_backup_data/alice/.ssh/authorized_keys`

No need to worry about file permissions. The server container will automatically fix them.


## 3. Setup the server (Using Docker command-line)
If you are using Docker compose natively from the command-line:

* Copy the [backup_server](../backup_server) folder to your server.
* Modify the [.env](../backup_server/.env) file to accommodate how your server
  is organized.
* Start the service:

```bash
cd backup_server
sudo docker compose up -d
```

## 3. Setup the server (Using OpenMediaVault)
If you are using OpenMediaVault's web-based Docker Compose utility:

* Copy the [backup_server_image](../backup_server/backup_server_image) folder to
  a known location in your NAS server. Make note of the absolute path to the folder.

  For example: `/my_services/backup_server/backup_server_image`
* Create a new "Compose" file in OMV
* Copy the contents of [compose.yaml](../backup_server/compose.yaml) into the "File" textbox.
* Edit the path specified by `build:` to point to where you saved the `backup_server_image` folder.

  For example: `build: /my_services/backup_server/backup_server_image`
* Copy the contents of [.env](../backup_server/.env) to the "Environment" text box
* Modify the environment variables to accommodate how your server is organized.
* Start the service


## 4. Forward the SSH port from WAN-->NAS
Forward the port specified by `SSH_PORT` so that external connections can access
the container


## 5. Test the connection
(assuming SSH_PORT=60022)

```bash
ssh alice@my_server_domain.com -p 60022
```
