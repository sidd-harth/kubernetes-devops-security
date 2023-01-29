pipeline {
  agent any

  stages {

    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
      }
    }

    stage('Unit Tests - JUnit and Jacoco') {
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
          docker.withRegistry(<registryUrl>, <registryCredentialsId>){
          sh 'printenv'
          sh 'docker build -t  Devsecops9849/kubernetes-devops-security :""$GIT_COMMIT"" .'
          sh 'docker push  Devsecops9849/kubernetes-devops-security :""$GIT_COMMIT""'
        }
      }
    }
  }
}
}