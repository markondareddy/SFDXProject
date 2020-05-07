#!groovy

node {

    def SF_CONSUMER_KEY=env.SF_CONSUMER_KEY
    def SF_USERNAME=env.SF_USERNAME
    def SERVER_KEY_CREDENTIALS_ID=env.SERVER_KEY_CREDENTIALS_ID
    def DEPLOYDIR='src'
	def UATDEPLOYER='uat-deployer/'
    def TEST_LEVEL='NoTestRun'
    def SF_INSTANCE_URL = env.SF_INSTANCE_URL ?: "https://test.salesforce.com"


    def toolbelt = tool 'toolbelt'
	def bitbash = tool 'bitbash'
	//def toolbelt = tool name: 'toolbelt', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
	echo "toolbelt = ${toolbelt}"

    // -------------------------------------------------------------------------
    // Check out code from source control.
    // -------------------------------------------------------------------------

    stage('checkout source') {
        checkout scm
    }


    // -------------------------------------------------------------------------
    // Run all the enclosed stages with access to the Salesforce
    // JWT key credentials.
    // -------------------------------------------------------------------------

 	withEnv(["HOME=${env.WORKSPACE}"]) {	
	
	    withCredentials([file(credentialsId: SERVER_KEY_CREDENTIALS_ID, variable: 'server_key_file')]) {
		// -------------------------------------------------------------------------
		// Authenticate to Salesforce using the server key.
		// -------------------------------------------------------------------------
		
		

		//stage('Update CLI') {
			//rc = bat returnStatus: true, script: "${toolbelt} update"
		    //if (rc != 0) {
			//error 'CLI update failed.'
		    //}
		//}
		
		stage('Authorize to Salesforce') {
			rc = bat returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --instanceurl ${SF_INSTANCE_URL} --clientid ${SF_CONSUMER_KEY} --jwtkeyfile ${server_key_file} --username ${SF_USERNAME} --setalias dev7org"
		    if (rc != 0) {
			error 'Salesforce org authorization failed.'
		    }
		}
		
		// get updated files
		stage('get update files from repo') {
			//rc = bat returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --instanceurl ${SF_INSTANCE_URL} --clientid ${SF_CONSUMER_KEY} --jwtkeyfile ${server_key_file} --username ${SF_USERNAME} --setalias dev7org"
			//rc = bat returnStatus: true, script: "${bitbash} git diff --name-only uat master | xargs git checkout-index -f --prefix=${UATDEPLOYER}" 
							
		    if (rc != 0) {
			error 'Salesforce org authorization failed.'
		    }
		}
		
		stage('call perl script') {
			//rc = bat returnStatus: true, script: "perl perl1.pl"
			rc = bat returnStatus: true, script: "perl DeployBuild.pl"
		    if (rc != 0) {
			error 'perl execution failed.'
		    }
		}
		

		// -------------------------------------------------------------------------
		// Convert metadata.
		// -------------------------------------------------------------------------

		stage('Convert Source to Metadata') {
		    //rc = bat returnStatus: true, script: "${toolbelt} force:source:convert --outputdir ${DEPLOYDIR}"
		    //if (rc != 0) {
			//error 'Salesforce convert source to metadata run failed.'
		    //}
		}
		
		// -------------------------------------------------------------------------
		// Deploy metadata and execute unit tests.
		// -------------------------------------------------------------------------

		stage('Deploy and Run Tests') {
		    //rc = bat returnStatus: true, script: "${toolbelt} force:mdapi:deploy --wait 10 --deploydir ${DEPLOYDIR} --targetusername dev7org --testlevel ${TEST_LEVEL}"
		    //if (rc != 0) {
			//error 'Salesforce deploy and test run failed.'
		    //}
		}


		// -------------------------------------------------------------------------
		// Example shows how to run a check-only deploy.
		// -------------------------------------------------------------------------

		//stage('Check Only Deploy') {
		//    rc = command "${toolbelt}/sfdx force:mdapi:deploy --checkonly --wait 10 --deploydir ${DEPLOYDIR} --targetusername dev7org --testlevel ${TEST_LEVEL}"
		//    if (rc != 0) {
		//        error 'Salesforce deploy failed.'
		//    }
		//}
	    }
	}
}

def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
		return bat(returnStatus: true, script: script);
    }
}