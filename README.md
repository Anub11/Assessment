# NGINX on EKS with ArgoCD

This repository contains Kubernetes manifests to deploy an NGINX web server on an EKS cluster using ArgoCD for GitOps-based continuous deployment.

---

## ☁️ Provision an EKS Cluster

### Prerequisites

- AWS CLI configured (`aws configure`)
- `kubectl` installed
- `eksctl` installed → [Install eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)

### Create an EKS Cluster

Step 1: Update kubeconfig for the EKS Cluster
Run the following command to update the kubeconfig file with your EKS cluster details:
aws eks --region ap-south-1 update-kubeconfig --name devopsshack-cluster
This command retrieves the kubeconfig configuration for the devopsshack-cluster and stores it in the default kubeconfig file (e.g., ~/.kube/config).
________________________________________
Step 2: Install kubectl
Follow these steps to install the latest version of kubectl:
1.	Download the kubectl binary:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
2.	Make the binary executable:
chmod +x kubectl
3.	Move the binary to a system PATH directory:
sudo mv kubectl /usr/local/bin/
4.	Verify the installation:
kubectl version --client
________________________________________
Step 3: Install eksctl
Follow these steps to install eksctl, a CLI tool for managing EKS clusters:
1.	Download the eksctl tarball:
curl -LO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
2.	Extract the tarball:
tar -xzf eksctl_Linux_amd64.tar.gz
3.	Move the binary to a system PATH directory:
sudo mv eksctl /usr/local/bin
4.	Verify the installation:
eksctl version



Step 4: Associate IAM OIDC Provider
Associate an IAM OIDC provider with your EKS cluster to enable IAM roles for Kubernetes service accounts:
eksctl utils associate-iam-oidc-provider --region ap-south-1 --cluster devopsshack-cluster --approve
This command associates the OIDC provider required for enabling IAM roles for service accounts in the EKS cluster.
________________________________________
Step 5: Create an IAM Service Account
Create a Kubernetes service account with IAM permissions for the Amazon EBS CSI Driver:
eksctl create iamserviceaccount \
  --region ap-south-1 \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster devopsshack-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --override-existing-serviceaccounts
•	--name ebs-csi-controller-sa: Name of the service account.
•	--namespace kube-system: Namespace where the service account will be created.
•	--attach-policy-arn: IAM policy ARN for EBS CSI Driver permissions.
•	--approve: Automatically approve the creation.
________________________________________
Step 6: Deploy the AWS EBS CSI Driver
Deploy the AWS EBS CSI Driver in the cluster using the following command:
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.11"
This command deploys the latest stable release of the EBS CSI Driver from the official repository.
________________________________________


### install ArgoCD
### Install ArgoCD in the argocd namespace:

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

### Wait for pods to be ready:

kubectl get pods -n argocd

### Access ArgoCD UI
### Option 1: Port-forward (for secure local access)

kubectl port-forward svc/argocd-server -n argocd 8080:443
### Then open: https://localhost:8080

### Option 2: LoadBalancer (Cloud Access)
### Patch the ArgoCD server to use LoadBalancer:

### kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
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
