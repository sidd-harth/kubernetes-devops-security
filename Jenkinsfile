pipeline {
  agent any
  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "bcorpse/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://34.87.96.252"
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
              parallel(
                "OPA Scan": {
                  sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa/opa-k8s-security.rego k8s_deployment_service.yaml'
                },
                "Kubesec Scan": {
                  sh "bash kubesec-scan.sh"
                },
                "Trivy Scan": {
                  sh "bash trivy-docker-image-scan.sh"
                },
              )
            }
        }
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
        stage('Integration Tests - DEV') {
          steps {
            script {
              try {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                  sh "bash integration-test.sh"
                }
              } catch (e) {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                  sh "kubectl -n default rollout undo deploy ${deploymentName}"
                }
                throw e
              }
            }
          }
        }
        stage('OWASP ZAP - DAST') {
          steps {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh 'bash zap.sh'
            }
          }
        }
    }
    post {
       always {
             junit 'target/surefire-reports/*.xml'
             jacoco execPattern: 'target/jacoco.exec'
             pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
             dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
             publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'HTML Report', reportTitles: 'OWASP ZAP REPORT', useWrapperFileDirectly: true])
       }
       
    }
}
