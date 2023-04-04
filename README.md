# Image App

This application uploads image to s3, stores the url to mongodb and cache it to redis.


This repository contains four parts
1. Static website for S3
2. Helm chart for EKS
3. Argo configration
4. Terraform Code

## Setup Environment

Infrastructure
```bash
cd terraform/vpc
terraform init
terraform plan
terraform apply

cd terraform/infrastructure
terraform init
terraform plan
terraform apply
```

Argo for Git Sync
```bash
cd argo
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Helm for initial Deployment
```bash
helm secrets upgrade -f ./secrets.yml -f ./values.yaml imageapp ./
```

## TODO
1. Change K8 service to ingress
2. Create domain
3. Refine sg rules for internal network
4. Helm notes file
5. VPC peering of MongoDB

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.