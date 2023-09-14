def call(String buildStatus = 'STARTED') {
 buildStatus = buildStatus ?: 'SUCCESS'

 def color

 if (buildStatus == 'SUCCESS') {
  color = '#47ec05'
 } else if (buildStatus == 'UNSTABLE') {
  color = '#d5ee0d'
 } else {
  color = '#ec2805'
 }

 def msg = "${buildStatus}: `${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL}"

 slackSend(color: color, message: msg)
}
