#!bin/bash
#set -e


# section to be commented out when using systemd service to manage this script
# may be useful when used as standalone script
declare -i waits
waits=0
while (( waits < 10 ));do
	waits=$(( waits + 1 ))
	if [[ "$(systemctl show hsbc-gcp-env-setup.service -p ActiveState)" == "ActiveState=activating" ]]; then
		echo "waiting for hsbc-gcp-env-setup.service to finish activating: attempt #$waits"
		sleep 1
	else
		break
	fi
done

NEED_TO_EXIT='false';

function healthCheckInSystemctl() {

COMMAND=$1
SERVICE_NAME=$2 
GREP_STRING=$3

SERVICE_STATUS=$(${COMMAND})
SERVICE IS ACTIVE ICE_IS_ACTIVE=$(echo ${SERVICE_STATUS} | grep 'Active: active (running)')

if [[ "${SERVICE_IS_ACTIVE}" == "" ]]; then
NEED_TO_EXIT='true';
fi
}

function healthCheckInService() {

COMMAND=$1
SERVICE_NAME=$2
GREP STRING=$3

SERVICE_STATUS=$ (${COMMAND})
SERVICE IS_ACTIVE=$(echo ${SERVICE_STATUS} | grep 'Provenir..............is running')

if [[ "${SERVICE_IS_ACTIVE}" == "" ]]; then 
NEED_TO_EXIT='true'
fi
}

healthCheckInService  "service prov7adm status"  "prov7adm"
healthCheckInService  "service prov7dep status"  "prov7dep"


#ENV=$(gcloud config get project); 
#IS_PRD_ENV=$(echo ${ENV} | grep 'prd');

#if [[ "${IS_PRD_ENV}" != " ]]; then
#healthCheckInSystemctl "systemctl status house_clean_service" "house_clean_service";
#fi

if [[ "${NEED_TO_EXIT}" = "true" ]]; then 
echo "unsuccessful";
else
shutdown +1;
fi