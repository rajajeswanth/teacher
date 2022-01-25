terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket  = "us-east-1-tf-state-storage"
    key     = "aws-fargate.tfstate"
    region  = "us-east-1"
    profile = "default"
  }
}
