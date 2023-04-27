pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }   
         stage('Unit Testcase') {
            steps {
              sh "mvn test"
              
            }
          
        }  
        stage('Mutation Tests - PIT') {
      steps {
        // Added
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
    
    } 



stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('sonarqube') {
              sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://ec2-18-118-168-165.us-east-2.compute.amazonaws.com:9000/"
        }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
      }
    }
  //  stage('Vulnerability Scan - Docker ') {
  //     steps {
  //       sh "mvn dependency-check:check"
  //     }
  //     post {
  //       always {
  //         dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
  //       }
  //     }
  //   }

         stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
          sh 'printenv'
          sh 'docker build -t mahesh430/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push mahesh430/numeric-app:""$GIT_COMMIT""'
        }
      }
    }
    
    stage('Kubernetes Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "sed -i 's#replace#mahesh430/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh "kubectl apply -f k8s_deployment_service.yaml"
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
    }
}
}