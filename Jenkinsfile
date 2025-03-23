pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }

      stage("Unit Test") {
          steps {
              sh "mvn test"
          }
          post {
              always {
                  junit 'target/surefire-reports/*.xml'
                  jacoco(execPattern: 'target/jacoco.exec')
              }
          }
      }


      stage('Dockker Build and Push') {
          steps {
              withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
              sh 'printenv'
              sh 'docker build -t suhailsap06/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push suhailsap06/numeric-app:""$GIT_COMMIT""'
          }
      }
    }

        stage('Kubernetes Deployment - Dev') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                sh 'sed -i 's#replace#suhailsap06/numeric-app:""$GIT_COMMIT""#g' k8s_deployment_service.yaml'
                sh 'kubectl apply -f k8s_deployment_service.yaml'
              }
          }
      }
  }
}