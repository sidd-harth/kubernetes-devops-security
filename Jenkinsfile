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
                script {
                    // Ensure GIT_COMMIT is populated
                    GIT_COMMIT = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    echo "Building and pushing Docker image for commit: ${GIT_COMMIT}"

                    // Docker login using credentials securely
                    withCredentials([usernamePassword(credentialsId: '90cf476e-ad01-40fe-86fa-4b0599ac41ff', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        
                        // Docker build and push commands
                        sh "docker build -t manlikeabz/numeric-app:${GIT_COMMIT} ."
                        sh "docker push manlikeabz/numeric-app:${GIT_COMMIT}"
                    }
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
