pipeline {
  agent any
  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "socool/kubernetes-devops-security:${GIT_COMMIT}"
    applicationURL = "http://34.87.96.252:30040/"
    applicationURI = "/increment/99"
  }
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
        } 
        stage('Mutation Tests - PIT') {
          steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
          }
        }
        stage('SonarQube - SAST') {
          steps {
            withSonarQubeEnv('SonarQube'){
              sh '''
                mvn sonar:sonar -Dsonar.projectKey=numeric-application \
                -Dsonar.host.url=http://34.87.96.252:9000
              '''
            }
            timeout(time: 2, unit: 'MINUTES'){
              script{
                waitForQualityGate abortPipeline: true
              }
            }
          }
        }
        stage('Vulnerability Scan - Docker ') {
          steps {
            parallel(
              "Dependency Scan":{
                sh "mvn dependency-check:check"
              },
              "Trivy Scan": {
                sh "bash trivy-docker-image-scan.sh"
              },
              "OPA Conftest": {
                sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa/dockerfile-security.rego Dockerfile'
              }
            )
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
        stage('Vulnerability Scan - Kubernetes') {
          steps {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa/opa-k8s-security.rego k8s_deployment_service.yaml'
          }
        }
        //stage('Kubernetes Deployment - DEV') {
        //     steps {
        //        withKubeConfig([credentialsId: 'kubeconfig']) {
        //           sh "sed -i 's#replace#bcorpse/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
        //           sh "kubectl apply -f k8s_deployment_service.yaml"
        //        }
        //    }
        //}
        stage('K8S Deployment - Dev'){
          steps{
            parallel(
              "Deployment":{
                withKubeConfig([credentialsId: 'kubeconfig']){
                  sh "bash k8s-deployment.sh"
                }
              },
              "Rollout Status":{
                withKubeConfig([credentialsId: 'kubeconfig']){
                  sh "bash k8s-deployment-rollout-status.sh"
                }
              }
            )
          }
        }
    }
    post {
       always {
             junit 'target/surefire-reports/*.xml'
             jacoco execPattern: 'target/jacoco.exec'
             pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
             dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
       }
       
    }
}
