pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'calculator-app'
        CONTAINER_NAME = 'calculator-container'
        APP_PORT = '5050'
        GITHUB_REPO = 'https://github.com/AlwinSibichan/Calculator-Webapp.git'
        GITHUB_BRANCH = 'main'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                // Clean workspace before checking out
                cleanWs()
                
                // Checkout code from GitHub
                git branch: env.GITHUB_BRANCH,
                    url: env.GITHUB_REPO
                
                // Log the current commit
                sh '''
                    echo "Current commit details:"
                    git log -1
                    echo "Branch information:"
                    git branch -v
                '''
            }
        }
        
        stage('Setup Environment') {
            steps {
                script {
                    // Add jenkins user to docker group
                    sh '''
                        if ! grep -q "^docker:" /etc/group; then
                            sudo groupadd docker
                        fi
                        sudo gpasswd -a jenkins docker
                        sudo service docker restart
                        newgrp docker
                    '''
                }
            }
        }
        
        stage('Build Application') {
            steps {
                script {
                    // Build Docker image with GitHub commit hash tag
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh """
                        # Build and tag Docker image
                        docker build -t ${DOCKER_IMAGE}:${commitHash} .
                        docker tag ${DOCKER_IMAGE}:${commitHash} ${DOCKER_IMAGE}:latest
                        docker images | grep ${DOCKER_IMAGE}
                    """
                }
            }
        }
        
        stage('Test Application') {
            steps {
                script {
                    sh """
                        # Stop and remove existing container if it exists
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                        
                        # Run the container in detached mode
                        docker run -d -p ${APP_PORT}:${APP_PORT} --name ${CONTAINER_NAME} ${DOCKER_IMAGE}:latest
                        
                        # Wait for container to start
                        sleep 10
                        
                        # Make test script executable and run tests
                        chmod +x test_calculator.sh
                        ./test_calculator.sh
                    """
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                script {
                    sh """
                        # Stop and remove existing container
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                        
                        # Deploy new container
                        docker run -d -p ${APP_PORT}:${APP_PORT} --name ${CONTAINER_NAME} ${DOCKER_IMAGE}:latest
                        
                        # Verify deployment
                        sleep 10
                        if ! curl -s http://localhost:${APP_PORT}/ > /dev/null; then
                            echo "Deployment verification failed"
                            exit 1
                        fi
                        
                        echo "Application deployed successfully at http://localhost:${APP_PORT}"
                    """
                }
            }
        }
    }
    
    post {
        always {
            script {
                sh """
                    # Archive container logs
                    docker logs ${CONTAINER_NAME} > container.log || true
                    docker ps -a > docker-status.log
                """
                
                // Archive the logs
                archiveArtifacts artifacts: '*.log', allowEmptyArchive: true
                
                // Cleanup
                sh """
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                """
            }
        }
        success {
            script {
                def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                echo "Pipeline completed successfully! Docker image tag: ${DOCKER_IMAGE}:${commitHash}"
            }
        }
        failure {
            script {
                echo 'Pipeline failed! Check the logs for details.'
            }
        }
    }
} 