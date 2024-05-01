pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerregistry'
        REMOTE_HOST = '54.158.234.194'
        REMOTE_USER = 'ec2-user'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    // Build the Java project
                    sh './mvnw clean package'
                }
            }
        }

        stage('Prepare Remote Environment') {
            steps {
                script {
                    sshagent(credentials: ['mudit_key']) {
                        // Copying the project files to the remote server
                        sh "rsync -avz --exclude '.git' -e 'ssh -o StrictHostKeyChecking=no' . ${REMOTE_USER}@${REMOTE_HOST}:/home/ec2-user/"
                    }
                }
            }
        }

        stage('Build and Tag Docker Image on Remote') {
            steps {
                script {
                    sshagent(credentials: ['mudit_key']) {
                        // Execute Docker build and tag commands remotely
                        sh '''
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} \
                            "cd /home/ec2-user/ && \
                             sudo docker build -t my-java-app:latest . && \
                             sudo docker tag my-java-app:latest muditsoni32/my-java-app:latest"
                        '''
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sshagent(credentials: ['mudit_key']) {
                        // Push the Docker image from remote server to Docker Hub
                        sh '''
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} \
                            "docker login -u muditsoni32 -p mudit#@12 && \
                            docker push muditsoni32/my-java-app:latest"
                        '''
                    }
                }
            }
        }

        stage('Deploy Docker Image') {
            steps {
                script {
                    sshagent(credentials: ['mudit_key']) {
                        // SSH into the target server and run the Docker container
                        sh '''
                        ssh -o StrictHostKeyChecking=no ec2-user@18.206.147.42 \
                            "sudo docker pull muditsoni32/my-java-app:latest && \
                            sudo docker run -d --name my-java-app1 -p 8080:8080 muditsoni32/my-java-app:latest"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed. Check the console output for errors.'
        }
    }
}
