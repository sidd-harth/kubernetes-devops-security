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
        script{
            withDockerRegistry(credentialsId: 'dockerreg', url: '') {
                image = docker.build("markmama/spring:$BUILD_NUMBER")
                image.push()
            }
        }
      }
    }
    stage("Helm Deploy to Local Cluster"){
        when{
            branch 'feature/*'
        }
        steps{
            script{}
            sh "helm upgrade --install k8-ops  --set image1.tag=$BUILD_NUMBER k8-sec/"
        }
        
    }
  }
}
