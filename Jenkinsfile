pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }

        }   

        stage('Unit Tests') {
            steps {
              sh "mvn test" // ok I am fine 
            }
        }
    }
    
}