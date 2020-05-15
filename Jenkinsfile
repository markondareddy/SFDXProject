#!groovy

node {

	def SF_CONSUMER_KEY
	def SF_USERNAME
	def SF_INSTANCE_URL
    def SERVER_KEY_CREDENTIALS_ID=env.SERVER_KEY_CREDENTIALS_ID	
    def DEPLOYDIR='src'
	def TEST_LEVEL='NoTestRun'
	def toolbelt = tool 'toolbelt'
	
	// ------------------------------------------------------------------------
    // Check out code from source control.
    // ------------------------------------------------------------------------
		stage('checkout source') {
        checkout scm
		}
	
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


	
}

def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
		return bat(returnStatus: true, script: script);
    }
}