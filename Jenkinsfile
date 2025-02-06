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
        
        stage('Setup Docker Permissions') {
            steps {
                // Add jenkins user to docker group if not already added
                sh '''
                    if ! groups jenkins | grep -q docker; then
                        sudo usermod -aG docker jenkins
                        echo "Added jenkins user to docker group"
                    fi
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
                        sleep 10  # Wait for container to start and healthcheck to pass
                    """
                    
                    // Basic health check
                    sh """
                        if ! curl -s http://localhost:${APP_PORT}/ > /dev/null; then
                            echo "Health check failed"
                            exit 1
                        fi
                    """
                    
                    // Run API tests
                    sh '''
                        # Test addition
                        RESULT=$(curl -s -X POST -H "Content-Type: application/json" -d '{"num1": 10, "num2": 5, "operation": "add"}' http://localhost:5050/calculate | jq -r .result)
                        if [ "$RESULT" != "15.0" ]; then
                            echo "Addition test failed"
                            exit 1
                        fi
                        
                        # Test multiplication
                        RESULT=$(curl -s -X POST -H "Content-Type: application/json" -d '{"num1": 10, "num2": 5, "operation": "multiply"}' http://localhost:5050/calculate | jq -r .result)
                        if [ "$RESULT" != "50.0" ]; then
                            echo "Multiplication test failed"
                            exit 1
                        fi
                        
                        echo "All tests passed successfully"
                    '''
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
                // Clean up and archive artifacts
                sh """
                    docker logs ${CONTAINER_NAME} || true
                    docker ps -a
                """
                // Archive the test results and logs
                archiveArtifacts artifacts: '**/test_results.txt,**/app.log', allowEmptyArchive: true
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
                // Send notification or perform cleanup if needed
                sh """
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                """
            }
        }
    }
} 