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

#
Running from SA terraform
#
echo "Installing Terraform"

function get_hashicorp_from_nexus() {
TARGET_DIR-$1
PRODUCT-$2
VERSION-$3
OS_VER-$4
EXT-$5


NEXUS_URL-"https://Wa3ZF2FB:gfubK1lJBr961pyIKSxPdz9h3rnpxxxxxx133coqgTkWZvA@gbmt-nexus.prd.fx.gbm.cloud.uk.hsbc/repository/hashicorp-releases/$(PRODUCTJ/$IVERSION)/$(PRODUCT)
TMP_FILE-S(TARGET_DIR)/$(PRODUCT)$[VERSION)$-OS_VER].$(EXT)
echo "Will download ${NEXUS_URL} to ${TMP_FILE}"
wget -user vagrant --password vagrant ${NEXUS_URL} -O $(TMP FILEN
#curl -u vagrant:vagrant -o ${TMP_FILE} ${NEXUS_URL}  
#curl -k -u vagrant:vagrant -o $(TMP_FILE) $(NEXUS URL) --ciphers DEFAULT@SECLEVEL-1


echo "Will unzip S{TMP_FILE} to ${TARGET_DIR}"
unzip -o $/{TMP_FILE} -d ${TARGET_DIR}


rm -f ${TMP_FILE}
sleep 1s
}

get_hashicorp_from_nexus "$(TERRAFORM_DIR)
get_hashicorp_from_nexus "$(TERRAFORM_DIR)

get_hashicorp_from_nexus "${TERRAFORM_DIR}" 'terraform' '0.12.29' 'linux amd64' 'zip'
get_hashicorp_from_nexus "${TERRAFORM_DIR}" 'terraform-provider-local' '1.4.0'  'linux amd64' 'zip'
get_hashicorp_from_nexus "${TERRAFORM_DIR}" 'terraform-provider-null'  '3.1.0'   'linux amd64' 'zip'
get_hashicorp_from_nexus "${TERRAFORM_DIR}" 'terraform-provider-google' '3.90.0'   'linux amd64' 'zip'
get_hashicorp_from_nexus "${TERRAFORM_DIR}" 'terraform-provider-google-beta'  '3.90.0'  'linux amd64' 'zip'

$<TERRAFORM_DIR]/terraform -v


echo "Terraform installation completed!!"
