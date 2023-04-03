terraform {
  backend "s3" {
    encrypt = true
    bucket  = "myonlytestbucket"
    key     = "tf-statefile/state-file.tfstate"
    region  = "us-east-1"
    profile = "test"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "test"
}

variable "region" {
  default = "us-east-1"
}

variable "private_availability_zone" {
  default = "us-east-1b"
}

variable "public_availability_zone" {
  default = "us-east-1a"
}

variable "name" {
  default = "imageapp"
}

variable "github" {
  default = "https://github.com/harisahmed001/sa-image-app.git"
}

variable "instance_eks" {
  default = "t2.small"
}

variable "redis_node" {
  default = "cache.t2.micro"
}

variable "bucket" {
  default = "imageappbucketfordev"
}

variable "test" {
  default = "test"
}