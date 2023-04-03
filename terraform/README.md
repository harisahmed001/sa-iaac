# Image App

This application uploads image to s3, stores the url to mongodb and cache it to redis.

## Run

Terraform VPC
```bash
cd vpc
terraform init
terraform plan
terraform apply
```

Terraform Infrastructure
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```