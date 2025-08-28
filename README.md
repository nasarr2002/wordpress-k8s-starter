# WordPress on Kubernetes — Minikube + Helm + Kustomize + ArgoCD + Jenkins

> Starter kit minimal pour Ubuntu 22.04 (laptop).

## Prérequis (Ubuntu 22.04)
```bash
# 1) Outils de base
sudo apt update && sudo apt install -y ca-certificates curl gnupg lsb-release apt-transport-https

# 2) Docker CE
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER  # (déconnecte/reconnecte ensuite)
docker --version

# 3) kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# 4) Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 5) Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 6) Kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

# 7) ArgoCD CLI (argocd)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
```

## Démarrage Minikube
```bash
minikube start --cpus=4 --memory=8192 --driver=docker
kubectl get nodes
```

## Docker Hub
```bash
docker login
# (optionnel) si vous avez une image custom: docker build -t <dockerhub_user>/wp-custom:dev . && docker push <dockerhub_user>/wp-custom:dev
```

## Déploiement rapide WordPress (Helm Bitnami) — namespace "wordpress"
```bash
kubectl create namespace wordpress || true
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Valeurs par défaut (dev)
helm upgrade --install wordpress bitnami/wordpress -n wordpress -f infra/helm/wordpress/values-dev.yaml
kubectl -n wordpress get pods
```

### Accès au site
```bash
# Expose via service NodePort (déjà configuré dans values-dev.yaml)
minikube service -n wordpress wordpress
# ou l'URL :
minikube service -n wordpress wordpress --url
```

## Arborescence du repo
```
infra/
  helm/wordpress/values-dev.yaml
  helm/wordpress/values-staging.yaml
  helm/wordpress/values-prod.yaml
  kustomize/base/*
  kustomize/overlays/dev/*
  kustomize/overlays/staging/*
  kustomize/overlays/prod/*
cd/
  argocd/namespace.yaml
  argocd/argocd-install.yaml
  argocd/app-wordpress.yaml
ci/
  Jenkinsfile
apps/
  README.md
```

## Installer ArgoCD dans le cluster (namespace argocd)
```bash
kubectl create namespace argocd || true
kubectl apply -n argocd -f cd/argocd/argocd-install.yaml

# Récupérer le mot de passe admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{{.data.password}}" | base64 -d; echo

# Exposer l'UI d'ArgoCD localement
kubectl -n argocd port-forward svc/argocd-server 8080:443
# UI: https://localhost:8080  (login: admin / <password ci-dessus>)
```

## Créer l'application ArgoCD pour WordPress
1. Poussez ce repo sur GitHub (ou GitLab) et notez l'URL HTTPS du repo.
2. Éditez `cd/argocd/app-wordpress.yaml` (section `repoURL:`) avec l'URL de votre repo.
3. Appliquez:
```bash
kubectl apply -f cd/argocd/app-wordpress.yaml
# Puis dans l'UI ArgoCD, "Sync"
```

## Jenkins (pipeline simple)
```bash
# Installation rapide (pod dans le cluster) :
kubectl create namespace ci || true
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade --install jenkins jenkins/jenkins -n ci -f ci/jenkins-values.yaml

# Récupérer le mot de passe admin Jenkins
printf $(kubectl get secret --namespace ci jenkins -o jsonpath="{{.data.jenkins-admin-password}}" | base64 -d);echo

# Exposer Jenkins localement
kubectl -n ci port-forward svc/jenkins 8081:8080
# UI: http://localhost:8081
```

Le pipeline `Jenkinsfile` :
- build optionnel d'image WordPress custom (si vous en avez une)
- `helm upgrade --install` avec la bonne values selon l'environnement
- étape scan sécurité Trivy (si installé dans l'agent)

> **Astuce temps court (2 jours)** : commencez par **Minikube + Helm WordPress** (30–45 min), puis **ArgoCD** (30 min), puis **Jenkins** (45–60 min). Les optimisations (HPA, TLS, Prometheus, etc.) peuvent venir ensuite.
