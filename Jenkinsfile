pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    environment { 
        cluster = "project-network-ecs-demo"
        service = "java-app"
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
                app = docker.build("project-network")
                }
            }
        }
        stage('Test'){
            steps {
                 echo 'Empty'
            }
        }
        stage('Push ECR') {
            steps {
                script{
                    docker.withRegistry('https://723865550634.dkr.ecr.ap-northeast-1.amazonaws.com/', 'ecr:ap-northeast-1:AWS') {
                        app.tag('v2')
                        app.push('v2')
                    }
                }
            }
        }
        stage('Deloy ECS'){
            steps{
                agent {
                    ECS {
                        withAws
                        inheritFrom 'task.json '
                        
                            
                        }
                      
                    }
                }
            }
        }
}
