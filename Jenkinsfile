pipeline {
  agent any
  environment {
    REPO_URL = 'https://github.com/nasarr2002/wordpress-k8s-starter.git'
    BRANCH   = 'main'
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh '''
          set -e
          git config user.name  "Jenkins"
          git config user.email "jenkins@example.com"
        '''
      }
    }

    stage('Bump last_build') {
      steps {
        sh '''
          set -e
          mkdir -p infra/helm/wordpress/.ci
          date -u +"%Y-%m-%dT%H:%M:%SZ" > infra/helm/wordpress/.ci/last_build
          echo "Bumped: infra/helm/wordpress/.ci/last_build"
          git add infra/helm/wordpress/.ci/last_build
          git commit -m "ci: bump last_build [skip actions]" || echo "Nothing to commit"
        '''
      }
    }

    stage('Push to GitHub') {
      steps {
        withCredentials([string(credentialsId: 'github-token', variable: 'GHTOKEN')]) {
          sh '''
            set -e
            git remote set-url origin https://nasarr2002:${GHTOKEN}@github.com/nasarr2002/wordpress-k8s-starter.git
            git push origin HEAD:${BRANCH}
          '''
        }
      }
    }
  }
  post {
    always {
      echo "Pipeline terminé."
    }
  }
}

