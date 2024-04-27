pipeline {
    agent any

    environment {
        // Set JVM options for Maven
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

        stage('Kubernetes Deployment - DEV') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh "kubectl config use-context ${AKS_CLUSTER_NAME}"
                    sh "sed -i 's#replace#manlikeabz/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                    sh "kubectl apply -f k8s_deployment_service.yaml"
                }
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
