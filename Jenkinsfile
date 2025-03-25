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

        stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
                always {
                    pitmutation mutationStatsFile: '**target/pit-reports/**/mutations.xml'
                }
            }
        }

        stage('SonarQube - SAST') {
            steps {
                    sh """mvn clean verify sonar:sonar \
                        -Dsonar.projectKey=numeric-application \
                        -Dsonar.projectName='numeric-application' \
                        -Dsonar.host.url=http://devsecops-k8.eastus.cloudapp.azure.com:9000 \
                        -Dsonar.token=sqp_ef2005110434e56499619798f7e2c3e072e1f5b9"""
            }
        }

        stage('Docker Build and Push') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                    sh 'printenv'
                    sh 'docker build -t suhailsap06/numeric-app:"$GIT_COMMIT" .'
                    sh 'docker push suhailsap06/numeric-app:"$GIT_COMMIT"'
                }
            }
        }

        stage('Kubernetes Deployment - Dev') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh "sed -i 's#replace#suhailsap06/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                    sh 'kubectl apply -f k8s_deployment_service.yaml'
                }
            }
        }
    }
}
