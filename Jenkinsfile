pipeline {
    agent any

    environment {
        SHORT_COMMIT   = "${env.GIT_COMMIT.take(7)}"
        DOCKER_IMAGE   = "shabaz7323/sample-node-app:${SHORT_COMMIT}"
        DOCKER_REGISTRY = "docker.io"
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
                sh """
                    echo "Building image: ${DOCKER_IMAGE}"
                    docker build -t ${DOCKER_IMAGE} .
                """
            }
        }

        stage('Unit Tests') {
            steps {
                sh "npm --prefix app test || true"
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh """
                        echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh """
                        export KUBECONFIG=${KUBECONFIG_FILE}
                        
                        echo "Updating Kubernetes deployment..."

                        kubectl set image deployment/${K8S_DEPLOYMENT} \
                            sample-node-app=${DOCKER_IMAGE} \
                            --namespace=${K8S_NAMESPACE} || true
                        
                        kubectl apply -f k8s/

                        kubectl rollout status deployment/${K8S_DEPLOYMENT} \
                            --namespace=${K8S_NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        always {
            sh "docker image prune -f || true"
        }
    }
}
