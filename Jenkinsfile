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
             post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
        }  
        stage('Mutation Tests - PIT') {
      steps {
        // Added
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
    } 

  stage('SonarQube ') {
            steps {
              sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://ec2-18-117-129-189.us-east-2.compute.amazonaws.com:9000 -Dsonar.login=8ca2e5a6847d76e1870aabf358af459107a298df"
            }
        }  




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
}