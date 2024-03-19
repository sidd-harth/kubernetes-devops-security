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
  }
}
