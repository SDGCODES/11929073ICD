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

NEED_TO_EXIT='false';

function healthCheckInSystemctl () {

COMMAND=$1
SERVICE_NAME=$2
GREP_STRING=$3

SERVICE_STATUS=$(${COMMAND})
SERVICE_IS_ACTIVE=$(echo ${SERVICE_STATUS} | grep 'Active: active (running)')

if [[ "${SERVICE_IS_ACTIVE}" == "" ]]; then
	NEED_TO_EXIT='true';
fi
}

healthCheckInService          "service prov7adm status"                           "prov7adm"
healthCheckInService          "service prov7dep status"                           "prov7dep"

ENV=$ (gcloud config get project);
IS_PRD_ENV=$ (echo ${ENV} | grep 'prd');

if [[ "${IS_PRD_ENV}" != "" ]]; then
	healthCheckInSystemctl     "systemctl status house_clean_service"             "house_clean_service"
fi

if [[ "${NEED_TO_EXIT}" = "true" ]]; then
  echo "unsuccessful";
else
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
	
	shutdown +1;
	
fi
	