pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }   
         stage('Unit Testcase') {
            steps {
              sh "mvn test"
              
            }
             post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
        }   
         stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'docker build -t mahesh430/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push mahesh430/numeric-app:""$GIT_COMMIT""'
        }
      }
    }
    }
}