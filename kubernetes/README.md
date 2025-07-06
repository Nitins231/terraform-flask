# 🚀 Kubernetes Deployment for Fullstack Signup App

This repository contains Kubernetes manifests for deploying a fullstack application consisting of:

- **Frontend**: Express.js
- **Backend**: Flask (Python)
- **Database**: MongoDB

---

## 🧱 Project Structure 

kubernetes/
├── backend/
│ └── [Dockerfile, app.py, requirements.txt]
├── frontend/
│ └── [Dockerfile, Templates{index.html}, package.json, app.js]
├── backend-deployment.yaml
├── frontend-deployment.yaml
└── README.md

## 🧰 Prerequisites

- [Docker](https://www.docker.com/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Internet access to pull base images (or push local builds to DockerHub)

---

## ⚙️ How to Deploy

### 1. Start Minikube
```bash
minikube start --driver=docker

eval $(minikube docker-env)

docker build -t flask-backend ./backend
docker build -t frontend-app ./frontend

kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml

minikube service frontend-service

📦 Environment Variables
Ensure these are set inside your backend's deployment:

MONGO_URI: MongoDB connection string

FLASK_ENV: development or production

🛠️ Troubleshooting
Use kubectl get pods to check pod status

Use kubectl logs <pod-name> to debug

Use minikube dashboard to visually inspect resources