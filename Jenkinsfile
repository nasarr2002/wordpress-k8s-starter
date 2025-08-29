pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/nasarr2002/wordpress-k8s-starter.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Docker build step (à compléter si tu pushes vers DockerHub ou GHCR)'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Déploiement sur Kubernetes (kubectl apply via ArgoCD plus tard)'
            }
        }
    }
}
