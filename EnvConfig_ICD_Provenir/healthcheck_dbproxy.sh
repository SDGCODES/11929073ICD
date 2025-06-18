#!/bin/bash
#set -e
# sec to be commented out when using systemd service to manager this script
#may be useful when used as standalone script
declare -i waits
waits=0
while (( waits < 0 )); do
	waits=$ (( waits + 1 ))
	if [[ "$(systemctl show abcd-gcp-env-setup.service -p Activate)" == "ActiveState=activating" ]]; then
		echo "waiting for abcd-gcp-env-setup.service to finish activating: attempt #$waits"
		sleep 1
  else
	break
	fi
done

env=
if [ $# -ne 1 ]; then
	echo "# param error"
	exit 1
else
	env=$1
fi


if [[ "${env}" = "prd" ]]; then
  export SERVICES_TO_BE_DISABLED=(
	google-startup-scripts
	google-shutdown-scripts
	sshd
	
	}
	
	for SERVICE in "${SERVICES_TO_BE_DISABLED[@]}"
	do
	
		echo "disable and mask ${SERVICE}"
		systemctl disable ${SERVICE}
		systemctl mask ${SERVICE}
	done
	
	
	# remove all users but system users
	for user in $(awk -F ':' '$3>=1000 {print $1}' /etc/passwd | grep -v 'provenir')
	do
		echo "deleting user $user"
		userdel -f $user
		echo "Done deleting user $user"
	done
	
fi
	
	shutdown +1;
	
	