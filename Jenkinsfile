pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/nasarr2002/wordpress-k8s-starter.git'
            }
        }

        stage('Build Docker image') {
            steps {
                sh 'echo "Building Docker image..."'
                // Exemple : sh 'docker build -t nasarr2002/wordpress-k8s:latest .'
            }
        }

        stage('Push Docker image') {
            steps {
                sh 'echo "Pushing image to DockerHub..."'
                // Exemple : sh 'docker push nasarr2002/wordpress-k8s:latest'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'echo "Deploying with ArgoCD..."'
                // Exemple : sh 'kubectl apply -f infra/helm/wordpress'
            }
        }
    }
}

