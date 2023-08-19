pipeline {
  agent any

  stages {
        stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' // add comment 
            }
        }   
        stage('Unit Test') {
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
        stage('Mutation Tests - PIT') {
          steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
          }
          post {
            always {
              pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            }
          }
        }
        stage('Docker Build and Push') {
             steps {
                withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                   sh 'printenv'
                   sh 'docker build -t bcorpse/numeric-app:""$GIT_COMMIT"" .'
                   sh 'docker push bcorpse/numeric-app:""$GIT_COMMIT""'
             }
         }
        }
        stage('Kubernetes Deployment - DEV') {
             steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                   sh "sed -i 's#replace#bcorpse/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                   sh "kubectl apply -f k8s_deployment_service.yaml"
                }
            }
        }
    }
}
