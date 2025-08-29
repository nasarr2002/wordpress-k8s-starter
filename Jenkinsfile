pipeline {
  agent any
  options { timestamps() }

  // ID du credential Jenkins "Username with password" (username = ton login GitHub, password = le PAT)
  environment { GIT_CRED = 'github-token' }

  stages {
    stage('Checkout') {
      steps {
        // Reprend la même source SCM que celle définie dans la config du job
        checkout scm
      }
    }

    stage('Bump file for ArgoCD') {
      steps {
        sh '''
          set -e
          TARGET_DIR="infra/helm/wordpress"
          mkdir -p "$TARGET_DIR/.ci"
          echo "build=$(date +%Y%m%d%H%M%S)" > "$TARGET_DIR/.ci/last_build"
          echo "Bumped: $TARGET_DIR/.ci/last_build"
        '''
      }
    }

    stage('Commit & Push') {
      steps {
        sh '''
          git config user.email "jenkins@local"
          git config user.name "Jenkins CI"
          git add infra/helm/wordpress/.ci/last_build || true
          git commit -m "CI: bump to trigger ArgoCD sync [skip ci]" || echo "Nothing to commit"
        '''
        withCredentials([usernamePassword(credentialsId: env.GIT_CRED, usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
          sh '''
            # Push via URL avec credentials (simple et fiable)
            git push https://${GIT_USER}:${GIT_PASS}@github.com/nasarr2002/wordpress-k8s-starter.git HEAD:main
          '''
        }
      }
    }
  }

  post {
    success { echo '✅ Push OK. ArgoCD va synchroniser automatiquement.' }
    failure { echo '❌ Échec du pipeline. Regarde la console pour la ligne qui casse.' }
  }
}
