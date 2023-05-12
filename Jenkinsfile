pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    stages {
         stage('Clone repository') { 
            steps { 
                script{
                checkout scm
                }
            }
        }

        stage('Build') { 
            steps { 
                script{
                docker.build("project-network")
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
                    docker.withRegistry('https://723865550634.dkr.ecr.ap-northeast-1.amazonaws.com/', 'ecr:ap-northeast-1:AWS') {
                        docker.push('project-network')
                    }
                }
            }
        }
    }
}