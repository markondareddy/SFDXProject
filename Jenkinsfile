#!groovy

node {

    def SF_CONSUMER_KEY
	def SF_USERNAME
	def SF_INSTANCE_URL
    def SERVER_KEY_CREDENTIALS_ID=env.SERVER_KEY_CREDENTIALS_ID	
    def DEPLOYDIR='src'
	def TEST_LEVEL='NoTestRun'
	def toolbelt = tool 'toolbelt'
	def triggers = []

	if(env.BRANCH_NAME == 'dev') {
		triggers << cron('H/1 * * * *') // every 1 minutes
		} else if(env.BRANCH_NAME == 'release') {
			triggers << cron('* * * * *') // daily between midnight & 2 AM
			} else {
				// no scheduled build
	}

	properties (
		[
        pipelineTriggers(triggers)
		]
	)

    // ------------------------------------------------------------------------
    // Select branch from repo and read values from Jenkins global variables
	// asssing values to variables.
    // ------------------------------------------------------------------------
		stage('select branch from source repository'){
			if (env.BRANCH_NAME == 'dev') {
				SF_CONSUMER_KEY=env.SF_CONSUMER_KEY_DEV
				SF_USERNAME=env.SF_USERNAME_DEV
				SF_INSTANCE_URL = env.SF_INSTANCE_URL_DEV							
			} else if (env.BRANCH_NAME == 'release') {
				SF_CONSUMER_KEY=env.SF_CONSUMER_KEY_RELEASE
				SF_USERNAME=env.SF_USERNAME_RELEASE
				SF_INSTANCE_URL = env.SF_INSTANCE_URL_DEV		
			}		
		}


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

		// -------------------------------------------------------------------------
		// Convert metadata.
		// -------------------------------------------------------------------------

		stage('Convert Source to Metadata') {
		    //rc = bat returnStatus: true, script: "${toolbelt} force:source:convert --outputdir ${DEPLOYDIR}"
		    if (rc != 0) {
			error 'Salesforce convert source to metadata run failed.'
		    }
		}
		
		// -------------------------------------------------------------------------
		// Deploy metadata and execute unit tests.
		// -------------------------------------------------------------------------

		stage('Deploy and Run Tests') {
		    //rc = bat returnStatus: true, script: "${toolbelt} force:mdapi:deploy --wait 10 --deploydir ${DEPLOYDIR} --targetusername dev7org --testlevel ${TEST_LEVEL}"
		    if (rc != 0) {
			error 'Salesforce deploy and test run failed.'
		    }
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
				
		//Email notifications.		
		stage('Send email') {
			def mailRecipients = "markonda.reddy@rrd.com"
			
			emailext attachLog: true, attachmentsPattern: 'generatedFile.txt',
			emailext body: '''${SCRIPT, template="groovy-html.template"}''',
			mimeType: 'text/html',
			subject: "[Jenkins] ${JOB_NAME}-Build# ${BUILD_NUMBER}",
			to: "${mailRecipients}",
			replyTo: "${mailRecipients}",
			recipientProviders: [[$class: 'CulpritsRecipientProvider']]
			}
			
			/*
			//Downstream configurations
			//stage ('Starting downstream job ') {
					//build job: '../workspace/fdx-multibranch-pipeline_release'
			//}
			*/
		
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