terraform {
  backend "s3" {
    encrypt = true
    bucket  = "myonlytestbucket"
    key     = "tf-statefile/state-file-vpc.tfstate"
    region  = "us-east-1"
    profile = "test"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "test"
}

variable "name" {
  default = "imageapp"
}

variable "region" {
  default = "us-east-1"
}

variable "private_availability_zone" {
  default = "us-east-1b"
}

variable "private_availability_zone_2" {
  default = "us-east-1d"
}

variable "public_availability_zone" {
  default = "us-east-1a"
}

variable "public_availability_zone_2" {
  default = "us-east-1c"
}