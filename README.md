# NGINX on EKS with ArgoCD

This repository contains Kubernetes manifests to deploy an NGINX web server on an EKS cluster using ArgoCD for GitOps-based continuous deployment.

---

## ☁️ Provision an EKS Cluster

### Prerequisites

- AWS CLI configured (`aws configure`)
- `kubectl` installed
- `eksctl` installed → [Install eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)

### Create an EKS Cluster

```bash
eksctl create cluster \
  --name nginx-cluster \
  --region ap-south-1 \
  --nodegroup-name linux-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 4 \
  --managed

install ArgoCD
Install ArgoCD in the argocd namespace:

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Wait for pods to be ready:

kubectl get pods -n argocd

Access ArgoCD UI
Option 1: Port-forward (for secure local access)

kubectl port-forward svc/argocd-server -n argocd 8080:443
Then open: https://localhost:8080

Option 2: LoadBalancer (Cloud Access)
Patch the ArgoCD server to use LoadBalancer:

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
Get the URL:


kubectl get svc argocd-server -n argocd
Use the EXTERNAL-IP to access the ArgoCD UI.

Login Credentials
Get the admin password:


kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo
Login using:

Username: admin

Password: (value from above)

Deploy NGINX with ArgoCD
Ensure your nginx-deployment.yaml and nginx-service.yaml are in a subdirectory (e.g., nginx/)

Update nginx-argocd-application.yaml with:



The correct path (e.g., nginx)

Apply the ArgoCD Application:

kubectl apply -f nginx-argocd-application.yaml
ArgoCD UI → Sync the application

Access NGINX
The NGINX service uses type: LoadBalancer so AWS will assign a public IP.

kubectl get svc nginx-service
Use the EXTERNAL-IP in your browser to access the NGINX welcome page.