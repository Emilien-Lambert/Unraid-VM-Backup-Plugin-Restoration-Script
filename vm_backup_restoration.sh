#!/bin/bash

# Colors for terminal
BLUE='\033[0;34m'
RED='\033[0;91m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'
BOLD='\033[1m'

check_yes() {
	while true; do
		read -r -p "Are You Sure? [Y/n] " input
		case $input in
		[yY][eE][sS] | [yY])
			break
			;;
		[nN][oO] | [nN])
			printf "Operation cancelled\n"
			exit 1
			;;
		*)
			printf 'Invalid input...\n'
			;;
		esac
	done
}

print_separator() {
	read myrows mycols < <(stty size)
	printf "\n"
	for i in $(seq 1 $mycols); do
		printf "#"
	done
	printf "\n"
}

get_informations() {
	print_separator
	printf "${RED}Make sure the informations is correct this script does not check errors.${RESET}\n\n"
	printf "${RED}Please check this before continuing.${RESET}\n" sur le dashboard
	printf "${RED}1) On the dashboard, delete your VM if it still exists ('Remove VM & Disks)'${RESET}\n"
	printf "${RED}2) Make sure all VMs are shut down'${RESET}\n"
	printf "${RED}3) Make sure your VMs Manager is turned ON before launching this operation.${RESET}\n"
	printf "${RED}   (settigns => VM Manager => Enable VMs: Yes)${RESET}"
	print_separator
	printf "\n"

	printf "${BOLD}Enter path of virtual machine backup folder, for eg:${RESET}\n"
	printf "/mnt/user/John-Doe/my_backup_folder\n"
	printf "...\n"
	printf "\nPath without the last / like this: \n"
	printf "${BLUE}/mnt/user/PATH_BACKUP_FOLDER${RESET}\n\n"
	read -p "Path of backup folder: " PATH_BACKUP_FOLDER

	print_separator
	printf "\n"
	printf "${BOLD}Enter name of virtual machine, like:${RESET}\n"
	printf "${GREEN}Ubuntu${RESET}\n"
	printf "\n"
	read -p "Name of vm folder: " VM_NAME

	print_separator
	printf "\n"
	printf "${BOLD}Enter date of backup, for eg:${RESET}\n"
	printf "20220124_0200_$VM_NAME.xml\n"
	printf "20220124_0200_vdisk1.img or .zst\n"
	printf "...\n"
	printf "\nDate like this: \n"
	printf "${YELLOW}20220124_0200${RESET}\n\n"
	read -p "Date of backup: " BACKUP_DATE
	printf "\n"

	print_separator
	printf "\n"
	printf "${BOLD}Checking information :${RESET}\n"
	printf "Your backup path is: ${BLUE}$PATH_BACKUP_FOLDER${RESET}\n"
	printf "Your vm name is: ${GREEN}$VM_NAME${RESET}\n"
	printf "Your backup date is: ${YELLOW}$BACKUP_DATE${RESET}\n\n"
	check_yes
	printf "\n"
}

restore_backup() {
	printf "${BOLD}Creation VM folder in domains directory${RESET}\n"
	printf "mkdir /mnt/user/domains/$VM_NAME\n\n"
	mkdir /mnt/user/domains/$VM_NAME

	BACKUP_FILE=$(echo $PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_vdisk1.img*)

	if [[ "$BACKUP_FILE" == *".zst" ]]; then
		printf "${BOLD}Extracting backup file${RESET}\n"
		printf "unzstd -C $PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_vdisk1.img.zst\n"
		unzstd -C $PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_vdisk1.img.zst
		BACKUP_FILE=$(echo $PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_vdisk1.img)
		printf "${GREEN}!! Extraction finished !!${RESET}\n\n"
	fi

	if [[ "$BACKUP_FILE" == *".img" ]]; then
		printf "${BOLD}Copy backup file to domains folder${RESET}\n"
		printf "cp $BACKUP_FILE /mnt/user/domains/$VM_NAME/vdisk1.img\n"
		cp $BACKUP_FILE /mnt/user/domains/$VM_NAME/vdisk1.img
		printf "${GREEN}!! Copy finished !!${RESET}\n\n"
	else
		printf "${RED}!!! Backup file not found !!!${RESET}\n\a"
		exit 1
	fi

	printf "${BOLD}Copy .xml file${RESET}\n"
	BACKUP_FILE=$(echo $PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_${VM_NAME}.xml)
	printf "cp $BACKUP_FILE /etc/libvirt/qemu/$VM_NAME.xml\n"
	cp $BACKUP_FILE /etc/libvirt/qemu/$VM_NAME.xml
	printf "${GREEN}!! Copy finished !!${RESET}\n\n"

	printf "${BOLD}Copy _VARS-pure-efi.fd file${RESET}\n"
	BACKUP_FILE=$(echo $PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}*_VARS-pure-efi.fd)
	CLEAN_BACKUP_FILE=${BACKUP_FILE:${#PATH_BACKUP_FOLDER}+${#VM_NAME}+${#BACKUP_DATE}+3}
	# +3 because there are two / and one _ in the file name
	printf "cp $BACKUP_FILE /etc/libvirt/qemu/nvram/$CLEAN_BACKUP_FILE\n"
	cp $BACKUP_FILE /etc/libvirt/qemu/nvram/$CLEAN_BACKUP_FILE
	printf "${GREEN}!! Copy finished !!${RESET}\n\n"
}

###
# Main
###

get_informations
restore_backup

print_separator
printf "${GREEN}Now turn off your Array and turn it back on.${RESET}\n"
printf "${GREEN}Your VM is restored${RESET}"
print_separator
