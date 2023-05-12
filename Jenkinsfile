pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
        IMAGE_REPO_NAME="project-network"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "723865550634.dkr.ecr.ap-northeast-1.amazonaws.com/project-network"
    }
    stages {
         stage('Clone repository') { 
            steps { 
                script{
                sh 'npm install express'
                checkout scm
                }
            }
            
        }

        stage('Build') { 
            steps { 
                script{
                 app = docker.build("project-network")
                }
            }
        }
        stage('Test'){
            steps {
                 echo 'Empty'
            }
        }
        stage('Deploy') {
            steps {
                script{
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "docker tag ${REPOSITORY_URI}/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }
}
