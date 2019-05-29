terraform {
  backend "s3" {
    bucket = "backend-eks-git280519"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}