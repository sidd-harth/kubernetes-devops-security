pipeline {
  agent any

  environment {
    // Set JVM options for Maven
    MAVEN_OPTS = "--add-opens java.base/java.lang=ALL-UNNAMED"
  }

  stages {
    stage('Build Artifact') {
      steps {
        // Use environment variable for Maven options
        sh 'mvn clean package -DskipTests=true'
        archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: true
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
        sh 'printenv'
        // Corrected variable usage for GIT_COMMIT
        sh "docker build -t manlikeabz/numeric-app:${GIT_COMMIT} ."
        sh "docker push manlikeabz/numeric-app:${GIT_COMMIT}"
      }
    }
    
}
