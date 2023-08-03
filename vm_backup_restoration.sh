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
			echo -e "Operation cancelled"
			exit 1
			;;
		*)
			echo -e 'Invalid input...'
			;;
		esac
	done
}

print_separator() {
  read -r _ mycols < <(stty size)
  printf "\n"
  for _ in $(seq 1 "$mycols"); do
      printf "#"
  done
  printf "\n"
}


get_information() {
	print_separator
	echo -e "${RED}Make sure the information's is correct this script does not check errors.${RESET}\n"
	echo -e "${RED}Please check this before continuing.${RESET}"
	echo -e "${RED}1) On the dashboard, delete your VM if it still exists ('Remove VM & Disks)'${RESET}"
	echo -e "${RED}2) Make sure all VMs are shut down'${RESET}"
	echo -e "${RED}3) Make sure your VMs Manager is turned ON before launching this operation.${RESET}"
	echo -e "${RED}   (settings => VM Manager => Enable VMs: Yes)${RESET}"
	print_separator
	printf "\n"

	echo -e "${BOLD}Enter path of virtual machine backup folder, for eg:${RESET}"
	echo -e "/mnt/user/John-Doe/my_backup_folder"
	echo "..."
	echo -e "\nPath without the last / like this:"
	echo -e "${BLUE}/mnt/user/PATH_BACKUP_FOLDER${RESET}\n"
	read -r -p "Path of backup folder: " PATH_BACKUP_FOLDER

	print_separator
	printf "\n"
	echo -e "${BOLD}Enter name of virtual machine, like:${RESET}"
	echo -e "${GREEN}Ubuntu${RESET}"
	printf "\n"
	read -r -p "Name of vm folder: " VM_NAME

	print_separator
	printf "\n"
	echo -e "${BOLD}Enter date of backup, for eg:${RESET}"
	echo -e "20220124_0200_$VM_NAME.xml"
	echo -e "20220124_0200_vdisk1.img or .zst"
	echo -e ""
	echo -e "\nDate like this: "
	echo -e "${YELLOW}20220124_0200${RESET}\n"
	read -r -p "Date of backup: " BACKUP_DATE
	printf "\n"

	print_separator
	printf "\n"
	echo -e "${BOLD}Checking information :${RESET}"
	echo -e "Your backup path is: ${BLUE}$PATH_BACKUP_FOLDER${RESET}"
	echo -e "Your vm name is: ${GREEN}$VM_NAME${RESET}"
	echo -e "Your backup date is: ${YELLOW}$BACKUP_DATE${RESET}\n"
	check_yes
	printf "\n"
}

restore_backup() {
	echo -e "${BOLD}Creation VM folder in domains directory${RESET}"
	echo -e "mkdir /mnt/user/domains/$VM_NAME\n"
  mkdir -p /mnt/user/domains/"$VM_NAME"

  BACKUP_FILES=("$PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_vdisk1.img"*)
  if [[ -e ${BACKUP_FILES[0]} ]]; then
      BACKUP_FILE="${BACKUP_FILES[0]}"
  else
      echo "Backup file not found: $BACKUP_FILE"
      exit 1
  fi


	if [[ "$BACKUP_FILE" == *".zst" ]]; then
		echo -e "${BOLD}Extracting backup file${RESET}"
		echo -e "unzstd -C $PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_vdisk1.img.zst"
		unzstd -C "$PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_vdisk1.img.zst"
		BACKUP_FILE="$PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_vdisk1.img"
		echo -e "${GREEN}!! Extraction finished !!${RESET}\n"
	fi

	if [[ "$BACKUP_FILE" == *".img" ]]; then
		echo -e "${BOLD}Copy backup file to domains folder${RESET}"
		echo -e "cp $BACKUP_FILE /mnt/user/domains/$VM_NAME/vdisk1.img"
		cp "$BACKUP_FILE" "/mnt/user/domains/$VM_NAME/vdisk1.img"
		echo -e "${GREEN}!! Copy finished !!${RESET}\n"
	else
		echo -e "${RED}!!! Backup file not found !!!${RESET}\n\a"
		exit 1
	fi

	echo -e "${BOLD}Copy .xml file${RESET}"
	BACKUP_FILE="$PATH_BACKUP_FOLDER/$VM_NAME/${BACKUP_DATE}_${VM_NAME}.xml"
	echo -e "cp $BACKUP_FILE /etc/libvirt/qemu/$VM_NAME.xml"
	cp "$BACKUP_FILE" "/etc/libvirt/qemu/$VM_NAME.xml"
	echo -e "${GREEN}!! Copy finished !!${RESET}\n"

	echo -e "${BOLD}Copy _VARS-pure-efi.fd file${RESET}"
	BACKUP_FILE=$(find "$PATH_BACKUP_FOLDER/$VM_NAME" -name "${BACKUP_DATE}*_VARS-pure-efi.fd" -print -quit)
	CLEAN_BACKUP_FILE=${BACKUP_FILE:${#PATH_BACKUP_FOLDER}+${#VM_NAME}+${#BACKUP_DATE}+3}
	# +3 because there are two / and one _ in the file name
	echo -e "cp $BACKUP_FILE /etc/libvirt/qemu/nvram/$CLEAN_BACKUP_FILE"
	cp "$BACKUP_FILE" "/etc/libvirt/qemu/nvram/$CLEAN_BACKUP_FILE"
	echo -e "${GREEN}!! Copy finished !!${RESET}\n"
}

###
# Main
###

get_information
restore_backup

print_separator
echo -e "${GREEN}Now turn off your Array and turn it back on.${RESET}"
echo -e "${GREEN}Your VM is restored${RESET}"
print_separator
