import com.cloudbees.plugins.credentials.CredentialsProvider;
import com.cloudbees.hudson.plugins.folder.Folder;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.SecretBytes;
import com.cloudbees.plugins.credentials.domains.Domain;
import org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl;
import java.nio.file.*;
import jenkins.model.Jenkins;


node ('cm-linux') {
	
	try{
	   
	   stage('base information') {
		sh """
			echo "Jenkins job is running on thr server, the information as below:"
			cat /etc/redhat-release
			hostname
			whoami
			gcloud -v
		"""
	}
		env.project='abcd-11929073-provicd-prod'
		env.serviceAccount="terraform@abcd-11929073-provicd-prod.iam.gserviceaccount.com"
		def keyFileName="abcd-11929073-provicd-prod-sa-terraform.json"
		def keyFileId="abcd-11929073-provicd-prod-sa-terraform"
		def folderName="abcd-11929073-icd"
	   
	echo "gcloud configuration"
	withCredentials([file(credentialsId: 'abcd-11929073-provicd-dev-terraform', variable: 'KEY_FILE')]) {
		 sh """
		 gcloud config set proxy/address googleapis-dev.gcp.cloud.hk.abcd
		 gcloud config set proxy/port 3128
		 gcloud config set proxy/type http_no_tunnel
		 gcloud auth activate-service-account ${serviceAccount} --key-file=${KEY_FILE}
		 gcloud config set project ${project}
		"""
		}
		
	stage('create new key-file') {
	sh """
		echo "list key before recreate key"
		gcloud iam service-account keys list --iam-account ${serviceAccount} --managed-by=user --sort-by=CREATED_AT
		gcloud iam service-account keys create ${keyFileName} --iam-account ${serviceAccount} --quiet
		gcloud iam service-account keys list --iam-account ${serviceAccount} --managed-by=user --sort-by=CREATED_AT
		cat ${keyFileName}
	"""
	}
	
	stage('delete old key-file') {
	KEY=sh(returnStdout: true, script: "gcloud iam service-account keys list --iam-account ${serviceAccount} --managed-by=user --limit=1 --format 'table[no-heading](KEY_ID,CREATED_AT:sort=1)' | cut -d' ' -f1").trim()
	sh "gcloud iam service-account keys create ${keyFileName} --iam-account ${serviceAccount} --quiet"
	}
	
	stage('update credentials') {
	 jsonContent = readFile "${keyFileName}"
	 def secretBytes = SecretBytes.fromBytes(jsonContent.getBytes())
	 
	 def fcs = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
	   org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl.class,
	   getFolder(folderName)
	   )
	   
	 def gcpSAToken
	 for (org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl fileCred : fcs) {
	 
		if(fileCred.id == keyFileId)
			gcpSAToken = fileCred
		}
	}
	def updatedCredentials = new FileCredentialsImpl(gcpSAToken.scope, gcpSAToken.id, gcpSAToken.description, gcpSAToken.fileName, secretBytes)
	
	updatedFolderCredentials(folderName, gcpSAToken, updatedCredentials)
	
	}
	currentBuild.result='SUCCESS'
	notifySuccess();
   } catch(Exception err) {
    echo "[ERROR EXCEPTION CATCH]: ${err}"

   currentBuild.result='FAILURE'
   
    notifyFailed();
    }
	}
	
@NonCPS
getFolder(folderName){
  def cloudbeesciFolder
  def allJenkinsItem = Jenkins.getInstance().getItems();
  for (currentJenkinsItem in allJenkinsItem)
    {
	  if(currentJenkinsItem != null && currentJenkinsItem instanceof Folder)
	   {
	   if(currentJenkinsItem.toString().contains(folderName))
	   cloudbeesciFolder = (Folder)currentJenkinsItem
	   
	  }
	 }
	 return cloudbeesciFolder
	}
	

/*@NonCPS
def updateFolderCredentials(folderName, oldCred, updatedCred){
    def credentials_store = Jenkins.getInstance()
    .getExtensionList(com.cloudbees.hudson.plugins.folder.properties.FolderCredentialsProvider.class)[0]
    .getStore(getFolder(folderName))

    def result = credentials_store.updateCredentials(
        com.cloudbees.plugins.credentials.domains.Domain.global(),
        oldCred,
        updatedCred
    )

    println "Update Result = $result"
}/*

 @NonCPS
updateFolderCredentials(folderName, oldCred, updatedCred){
    def credentials_store = Jenkins.getInstance()
    .getExtensionList(com.cloudbees.hudson.plugins.folder.properties.FolderCredentialsProvider.class)[0]
    .getStore(getFolder(folderName))
        
    result = credentials_store.updateCredentials(
        com.cloudbees.plugins.credentials.domains.Domain.global(),
        oldCred,
        updatedCred
    )
    println "Update Result = $result"
}


	
def notifySuccess() { 
	print("This job has built successfully")
	
	def mailtemplate = "Hi,\n\n"
	mailtemplate += "New key has been provisoned for Service Acoount: ${env.serviceAccount} .\n\n"
	mailtemplate += "Below the key for your reference: \n\n${jsonContent}\n\n"
	
	emailext (
		subject:"SA key renew for ${env.project}",
		body:"The log: ${env.BUILD_URL}",
		to: "soumi.dasgupta@noexternalmail.abcd.com,Hrittik.s@abcd.co.in"
		)
	}
	
def notifyFailed() {
    print("This job built is failed and sending mail to notify")
	
	
	emailext (
		subject:"Failed Pipeline * ${currentBuild.fullDisplayName}",
		body:"${currentBuild.projectName} got some error, please check the log: ${env.BUILD_URL}.",
		to: "soumi.dasgupta@noexternalmail.abcd.com,Hrittik.s@abcd.co.in"
		)
	}
	
	
	
	
	
	
	