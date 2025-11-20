pipeline {
    agent any

    environment {
        SHORT_COMMIT   = "${env.GIT_COMMIT.take(7)}"
        DOCKER_IMAGE   = "shabaz7323/sample-node-app:${SHORT_COMMIT}"
        K8S_DEPLOYMENT = "sample-node-app-deployment"
        K8S_NAMESPACE  = "default"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                    echo Building image: ${DOCKER_IMAGE}
                    docker build -t ${DOCKER_IMAGE} .
                """
            }
        }

        stage('Unit Tests') {
            steps {
                bat "npm --prefix app test || exit 0"
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', 
                        usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {

                    bat """
                        echo %DOCKERHUB_PASS% | docker login -u %DOCKERHUB_USER% --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {

                    // Windows PowerShell commands for kubectl
                    powershell """
                        \$env:KUBECONFIG='${KUBECONFIG_FILE}'
                        kubectl apply -f k8s
                        kubectl set image deployment/${K8S_DEPLOYMENT} sample-node-app=${DOCKER_IMAGE} -n ${K8S_NAMESPACE}
                        kubectl rollout status deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        always {
            bat "docker image prune -f"
        }
    }
}
