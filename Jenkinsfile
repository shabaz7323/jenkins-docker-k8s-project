pipeline {
  agent any
  environment {
    DOCKER_IMAGE = "shabaz7323/sample-node-app:${GIT_COMMIT, substring:0, 7}"
    DOCKER_REGISTRY = "docker.io"
    K8S_DEPLOYMENT = "sample-node-app-deployment"
    K8S_NAMESPACE = "default"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build') {
      steps {
        sh 'docker build -t $DOCKER_IMAGE .'
      }
    }
    stage('Unit Test') {
      steps {
        sh 'npm --prefix app test || true'
      }
    }
    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
          sh '''
            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin ${DOCKER_REGISTRY}
            docker push $DOCKER_IMAGE
          '''
        }
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            export KUBECONFIG=$KUBECONFIG_FILE
            kubectl set image deployment/${K8S_DEPLOYMENT} sample-node-app=$DOCKER_IMAGE --namespace=${K8S_NAMESPACE} || kubectl apply -f k8s/
            kubectl rollout status deployment/${K8S_DEPLOYMENT} --namespace=${K8S_NAMESPACE}
          '''
        }
      }
    }
  }
  post {
    always {
      sh 'docker image prune -f || true'
    }
  }
}
