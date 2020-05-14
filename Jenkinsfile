#!groovy

node {

	def SF_CONSUMER_KEY
	def SF_USERNAME
	def SF_INSTANCE_URL
    def SERVER_KEY_CREDENTIALS_ID=env.SERVER_KEY_CREDENTIALS_ID	
    def DEPLOYDIR='src'
	def TEST_LEVEL='NoTestRun'
	def toolbelt = tool 'toolbelt'
	
	if (env.BRANCH_NAME == 'release') {
    //build 'markondareddy/sfdxproject/release'
	build job: 'build', parameters: [[$class: 'StringParameterValue', name: 'target', value: target], [$class: 'ListSubversionTagsParameterValue', name: 'release', tag: release], [$class: 'BooleanParameterValue', name: 'update_composer', value: update_composer]]
	}
}

def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
		return bat(returnStatus: true, script: script);
    }
}