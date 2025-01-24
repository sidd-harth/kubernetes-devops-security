pipeline {
  agent any
  tools {
    maven 'maven_home'
  }


  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
      stage('Kube-version check') {
            steps {
                withEnv(['KUBECONFIG=/home/jenkins/.kube/config']) {
                      sh "kubectl get all"
                }
            }
        }
    }
}
