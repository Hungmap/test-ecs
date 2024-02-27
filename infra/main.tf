terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.55.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}
module "vpc" {
  source         = "./vpc"
  vpc_cidr_block = "10.0.0.0/16"
  Private_subnet = ["10.0.10.0/24", "10.0.20.0/24"]
  Public_subnet  = ["10.0.1.0/24", "10.0.2.0/24"]
  az             = ["ap-southeast-1a", "ap-southheast-1c"]
}
module "ec2" {
  source         = "./EC2"
  vpc            = module.vpc
  sg_public      = module.vpc.sg_public
  subnet_public  = module.vpc.subnet_public
  sg_private     = module.vpc.sg_private
  subnet_private = module.vpc.subnet_private
  az             = ["ap-southeast-1a", "ap-southeast-1c"]


}
