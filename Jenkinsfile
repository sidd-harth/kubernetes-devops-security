pipeline {
    agent any

    environment {
        // Set JVM options for Maven
        deploymentName = "devsecops"
        containerName = "devsecops-container"
        serviceName = "devsecops-svc"
        imageName = "manlikeabz/numeric-app:${GIT_COMMIT}"
        applicationURL = "http://devsecops-abzconsultancies.eastus.cloudapp.azure.com/"
        applicationURI = "/increment/99"
        MAVEN_OPTS = "--add-opens java.base/java.lang=ALL-UNNAMED"
        AKS_CLUSTER_NAME = 'Devsecops-aks'
        NAMESPACE = 'default'
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

        stage('Mutation Tests - PIT') {
            steps {
                sh 'mvn org.pitest:pitest-maven:mutationCoverage'
            }
            post {
                always {
                    pitmutation mutationStatsFile: '**/pit-reports/**/mutations.xml'
                }
            }
        }

        stage('SonarQube - SAST') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://devsecops-abzconsultancies.eastus.cloudapp.azure.com:9000 -Dsonar.token=squ_b0ffa602f401442384e12c06cbd73a66b51a7d2a"
                    // Make sure the SonarQube scanner has finished before proceeding
                }
                script {
                    // It will wait indefinitely for the SonarQube analysis to complete
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                        error "Quality gate not passed: ${qg.status}"
                    }
                }
            }
        }

        stage('Vulnerability Scan - Docker') {
            parallel {
                stage('Maven Dependency Check') {
                    steps {
                        script {
                            sh "mvn dependency-check:check"
                        }
                    }
                    post {
                        always {
                            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                        }
                    }
                }
                stage('Trivy Scan') {
                    steps {
                        script {
                            sh "bash trivy-docker-image-scan.sh"
                            //trivy image --exit-code 0 --severity HIGH,CRITICAL manlikeabz/numeric-app:${GIT_COMMIT}
                        }
                    }
                }
                stage('OPA Conftest') {
                    steps {
                        script {
                            // Run OPA Conftest against the Dockerfile
                            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
                        }
                    }
                }
            }
        }

        stage('Docker Build and Push') {
            steps {
                script {
                    // Ensure GIT_COMMIT is populated
                    GIT_COMMIT = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    echo "Building and pushing Docker image for commit: ${GIT_COMMIT}"

                    // Docker login using credentials securely
                    withDockerRegistry([credentialsId: "90cf476e-ad01-40fe-86fa-4b0599ac41ff", url: ""]) {
                        sh "printenv"

                        // Docker build and push commands
                        sh "docker build -t manlikeabz/numeric-app:${GIT_COMMIT} ."
                        sh "docker push manlikeabz/numeric-app:${GIT_COMMIT}"
                    }
                }
            }
        }

        // stage('Vulneability Scan - Kubernetes') {
        //     steps {
        //         script {
        //             // Run OPA Conftest scan against the Kubernetes deployment file
        //             sh "docker run --rm -v $pwd:/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml"
        //         }
        //     }
        // }

        stage('Vulnerability Scan - Kubernetes') {
            steps {
                parallel(
                    "OPA Scan": {
                        script {
                            // Run OPA Conftest scan against the Kubernetes deployment file
                            sh "docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml"
                        }
                    },
                    "Kubesec Scan": {
                        sh "bsh kubesec-scan.sh"
                    }
                    }
                )
            }
        }

        // stage('Kubernetes Deployment - DEV') {
        //     steps {
        //         withKubeConfig([credentialsId: 'kubeconfig']) {
        //             sh "kubectl config use-context ${AKS_CLUSTER_NAME}"
        //             sh "sed -i 's#replace#manlikeabz/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
        //             sh "kubectl apply -f k8s_deployment_service.yaml"
        //         }
        //     }
        // }

        stage('Integration Tests - DEV') {
            steps {
                script {
                  try {
                    withKubeConfig([credentialsId: 'kubeconfig']) {
                      sh "bash integration-tests.sh"
                    }
                  } catch (Exception e) {
                    withKubeConfig([credentialsId: 'kubeconfig']) {
                      sh "kubectl rollout undo deployment ${deploymentName}"
                    }
                    throw e  
                }
            }
        }

        stage('K8s Deployment - Dev'){
            steps{
              parallel(
                "Deploynment": {
                  withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh "bash k8s-deployment.sh"
                  }
                },
                "Rollout Status": {
                  withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh "bash k8s-deployment-rollout-status.sh"
                  }
                }
              )
            }
        }
    }

    post {
        always {
            // Cleanup after Docker to avoid logged in credentials hanging around
            sh "docker logout"
            echo 'Pipeline execution complete.'
        }
    }
}
