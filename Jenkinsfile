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
    stage('Coverage Test') {
      steps {
        sh 'mvn test'
      }
    }
    stage("Docker version check"){
      steps{
          withDockerRegistry(credentialsId: 'dockerreg', url: '') {
            docker build -t markmama/spring:${env.BUILD_ID}
            docker push markmama/spring:${env.BUILD_ID}
          }
      }
    }
  }
}


