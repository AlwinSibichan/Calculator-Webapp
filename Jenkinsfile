pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'calculator-app'
        CONTAINER_NAME = 'calculator-container'
        APP_PORT = '5050'
        GITHUB_REPO = 'https://github.com/yourusername/calculator-app.git'
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
        
        stage('Build Application') {
            steps {
                script {
                    // Build Docker image with GitHub commit hash tag
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh """
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
                    // Stop and remove existing container if it exists
                    sh """
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    """
                    
                    // Run the container in detached mode
                    sh """
                        docker run -d -p ${APP_PORT}:${APP_PORT} --name ${CONTAINER_NAME} ${DOCKER_IMAGE}:latest
                        sleep 5  # Wait for container to start
                    """
                    
                    // Run the test script
                    sh """
                        chmod +x test_calculator.sh
                        ./test_calculator.sh
                    """
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                script {
                    // Stop and remove existing container
                    sh """
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    """
                    
                    // Deploy new container
                    sh """
                        docker run -d -p ${APP_PORT}:${APP_PORT} --name ${CONTAINER_NAME} ${DOCKER_IMAGE}:latest
                        
                        # Verify deployment
                        sleep 5
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
            // Clean up Docker resources and archive test results
            script {
                sh """
                    docker logs ${CONTAINER_NAME} || true
                    docker ps -a
                """
                // Archive the workspace
                archiveArtifacts artifacts: '**/test_calculator.sh', allowEmptyArchive: true
            }
        }
        success {
            script {
                def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                echo "Pipeline completed successfully! Docker image tag: ${DOCKER_IMAGE}:${commitHash}"
            }
        }
        failure {
            echo 'Pipeline failed! Check the logs for details.'
        }
    }
} 