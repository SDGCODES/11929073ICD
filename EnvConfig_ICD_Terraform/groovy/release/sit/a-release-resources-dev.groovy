node ('cm-linux') {
	def RELEASE_FAIL_DEV = '[Release RESOURCES] Fail for Dev'
	def RELEASE_SUCCESS_DEV = '[Release RESOURCES] for Dev'
	try{
		env.project='abcd-11929073-provicd-dev'
		def TMP_SCRIPT_FILE="${WORKSPACE}/releaseDeployment"
		def CONFIG_SAVE_PATH="${TMP_SCRIPT_FILE}/resources"
		def BUCKET_URL="gs://abcd-12214544-provuk-dev/Provenir_v9.5.8.1/deploymentscript-9.5.8.1.zip"
	   def SAVE_PATH="${TMP_SCRIPT_FILE}/deploymentscript-9.5.8.1.zip"
	   
	   stage('base') {
		echo "Jenkins job is running on thr server, the information as below:"
		sh 'cat /etc/redhat-release'
		sh 'hostname'
		sh 'whoami'
	}
		
	echo "gcloud configuration"
	withCredentials([file(credentialsId: 'abcd-11929073-provicd-dev-terraform', variable: 'KEY_FILE')]) {
		sh "gcloud config set proxy/address googleapis-dev.gcp.cloud.hk.abcd"
		sh "gcloud config set proxy/port 3128"
		sh "gcloud config set proxy/type http_no_tunnel"
		sh "gcloud auth activate-service-account-terraform@abcd-11929073-provicd-dev.iam.gserviceaccount.com --key-file=${KEY_FILE}"
		sh "gcloud config set project ${project}"
		sh "gcloud config list"
		
		if(!fileExists('releaseDeployment/deploymentscript-9.5.8.1.zip')) {
		  sh """
		    echo "create directory ${TMP_SCRIPT_FILE}"
			rm -rf ${TMP_SCRIPT_FILE}
			mkdir -p ${TMP_SCRIPT_FILE}
			
			gcloud storage cp ${BUCKET_URL} ${SAVE_PATH}
			
			echo "unzip deploy management script"
			cd ${TMP_SCRIPT_FILE}
			tar -zxvf deploymentscript-9.5.8.1.zip
			
			echo "list the path ${TMP_SCRIPT_FILE}"
			ls ${TMP_SCRIPT_FILE}
			
			"""
		  }	
		}
		
		stage('export and import Resources') {
		 dir("${TMP_SCRIPT_FILE}/provenir70/bin") {
		 
			echo 'export Resources from UK SIT ICD ENV'
		downloadResult=sh(retutnStdout: true, script: "sh ./repocl.sh EXPORT_RESOURCES -r https://sit.abcd-11929073-provicd-dev.dev.gcp.cloud.uk.abcd:8443/Repository -e ICD_DEV_BKUP -f ${CONFIG_SAVE_PATH} -u SVC-NEXUS-RM -p jguhur583457te4irfsi884t49589fjesnfsk~f").trim()
		 if(downloadResult != 'HTTP/1.1 200 OK') {
			error("An execption occured while export resouces!")
			}
			echo '====================================='
			
		sh "ls -ltr ${CONFIG_SAVE_PATH}"
		echo '=============================='
		
		 if(Icdsit.toBoolean()) {
		   echo 'import Resources to UK SIT ICD ENV'
		    sh "sh ./repocl.sh IMPORT_RESOURCES -r https://sit.abcd-11929073-provicd-dev.dev.gcp.cloud.uk.hsbc:8443/Repository -e ICD_SIT_RM_TEST -f ${CONFIG_SAVE_PATH} -u SVC-NEXUS-RM -p jguhur583457te4irfsi884t49589fjesnfsk~f"
		    echo '====================================='
		}
	}
	
}

currentBuild.result='SUCCESS'
// emailNotification(RELEASE_SUCCESS_DEV)
}catch (Exception err) {
	echo "[ERROR EXCEPTION CATCH]: ${err}"
	currentBuild.result='FAILURE'
	 //emailNotification(RELEASE_FAIL_DEV)
	}
}

def emailNotification(emailSubject) {
	emailtext (
			subject:"${emailSubject}",
			body:"The log: ${env.BUILD_URL}",
			to: "soumi.dasgupta@noexternalmail.abcd.com;Hrittik.s@abcd.co.in"
	}
}