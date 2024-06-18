#!/usr/bin/env bash
REPO_PATH="${HOME}/.lil-dotties"
SCRIPTS_PATH="${HOME}/.lil-scripts"
BACKUP_PATH="${HOME}/.lil-backups"

# Bring in lib code
function load-lib-code {
	for f in "${SCRIPTS_PATH}"/*; do
		[ -e "$f" ] || continue
		source $f
	done
}

function config {
   git --git-dir="${REPO_PATH}" --work-tree="${HOME}" $@
}

function clone-bare-repo {
	git clone --bare https://github.com/NickLediet/lil-dotties.git "${REPO_PATH}"
}

function create-backup {
	# Create backup directory if it isn't defined
	if [ ! -d "${BACKUP_PATH}" ]; then
		mkdir -p "${BACKUP_PATH}"
	fi

	# Timestamp for backup
	FILE_HASH=$(date +%s)
	# Timestaped & user id'd subdirectory for this particular backup
	CURRENT_BACKUP_SUBDIR="${BACKUP_PATH}/${FILE_HASH}-$(whoami)-backup"

	# Create the directory for this backup
	mkdir "${CURRENT_BACKUP_SUBDIR}"

	# Get any unchecked files for backing up (This only checks files that conflict with lil-dotties)
	FILES=$(config checkout 2>&1 | egrep "\s+\." | awk {'print $1'})
	for FILE_PATH in "${FILES}"; do
		# Back em up!
		mv "${FILE_PATH}" "${CURRENT_BACKUP_SUBDIR}"
	done
}

function _install {
	clone-bare-repo
	config config --unset status.showUntrackedFiles
	load-lib-code

#	yesno_exit "Do you wish to run the install script for lil-dotties?"

	# Verify if changes have been made and create backups if required
	config checkout 
	if [ $? = 0 ]; then
		echo "Checked out configuration."
	else
		echo "Backing up existing dotfiles"
		create-backup
	fi
	config checkout
	config config --local status.showUntrackedFiles no
		
}
_install

