# Unraid-VM-Backup-Plugin-Restoration-Script

## Description

A bash script to automate the restoration of a virtual machine that has been backed up with the VM-Backup plugin on a Unraid server

## How it works?

### Video guide

http://www.youtube.com/watch?v=OIQKQPqLUfw

(For Windows VMs, it may be necessary to rename the _VARS-pure-efi-tpm.fd files and remove "tpm")

[![How to restore an Unraid virtual machine automatically](https://img.youtube.com/vi/OIQKQPqLUfw/0.jpg)](http://www.youtube.com/watch?v=OIQKQPqLUfw)


### Guide

#### Enter the following commands:

```bash
cd /mnt/user/SHARE NAME/BACKUP FOLDER
git clone https://github.com/Emilien-Lambert/Unraid-VM-Backup-Plugin-Restoration-Script.git
```
This will clone the script to your backup folder.

#### Enter the following commands:

```bash
cd Unraid-VM-Backup-Plugin-Restoration-Script
chmod +x vm_backup_restoration.sh
./vm_backup_restoration.sh
```
This will begin the script.

#### Do the following:

- Delete the VM you want to restore. Select Remove VM & Disks.
- Shut down all other VMs.
- Make sure the VM service is ENABLED/ON in Settings > VM Manager.

#### Enter the path of VM backups.

- Example: /mnt/user/SHARE NAME/BACKUP FOLDER/VMs

#### Enter name of VM you wish to restore.

- This will be the name of the folder of the VM you want to restore.
- Example: Ubuntu

#### Enter the date of the backup you want restored.

- For example, if the filename of the VM is 20220124_0300_Ubuntu.xml
- Just enter 20220124_0300

The restoration process could take several minutes.  
Once complete, stop your Unraid storage array and start it again.

Your newly restored VM will show up.

(Thanks to [devanteweary](https://github.com/devanteweary) for the written description)

## Why?

The VM Backup plugin is really great it allows you to make backups of your virtual machines, but at the moment it is not possible to restore a backup from the Unraid web interface. That's why I decided to create a small script to automate the restoration of a backup.

## About this repository

I am not an expert in bash script so there are probably many ways to improve this script. I would like to take into account your remarks or improvement if you want to participate to the improvement of this script. I put an MIT license I guess it's just for this kind of project.

## Documentation

VM Backup plugin :
<https://forums.unraid.net/topic/86303-vm-backup-plugin/>
