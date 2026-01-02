# Setting up the client backup script

This is the script that encrypts and copies your backup files to the remote server.
The assumption is that the backup script will run from your NAS.


## 0. Requirements

Install some prerequisites on your NAS:
```bash
sudo apt install gocryptfs rsync
```

Confirm you are able to login to your friend's server where you will store your backups:
```bash
ssh alice@their_server_domain.com -p 60022
```

## 1. Download and modify files

* Copy the [backup_client](../backup_client) folder somewhere to your NAS.

  For example: `/my_services/backup_client`

* Rename `backup.conf.TEMPLATE` --> `backup.conf`
* Modify `backup.conf` with your settings

## 2. Set up gocryptfs's encryption key

Run the `first_time_init.sh` script:
```bash
cd /my_services/backup_client
./first_time_init.sh
```

> **Important**
> This command will display a **master key**.
> Save this somewhere safe that will survive total destruction of your home
> (or just your NAS)
>
> This step creates a `gocryptfs.conf` file that contains keys to encrypt
> and decrypt your files automatically. If this file is lost (house burns down),
> then the **master key** is the only way to decrypt your backups!


## 3. Test that everything works

Recommend modifying `backup_dirs` in `backup.conf` to only point to some small test
folder before attempting a large backup.

For example's sake, assume this folder's path is: `/path/to/my/files`

Run the backup manually:
```bash
./backup.sh
```

Try restoring files to `my_restored_dir`:
```bash
./restore.sh  /path/to/my/files  my_restored_dir
```

Try restoring using the master key from before:
```bash
./restore.sh --master-key xxxxx-xxxxx-xxxxx-xxxxx  /path/to/my/files  my_restored_dir
```

## 4. Schedule periodic backups
Set up a scheduled task that calls the `backup.sh` script. (cronjob or whatever)
