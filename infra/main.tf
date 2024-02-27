terraform {
  cloud {
    organization = "hungnt1"
    workspaces {
      name = "infra"
    }
  }


}
provider "aws" {
  region  = "ap-southeast-1"
  version = "4.55"
}
module "vpc" {
  source         = "./vpc"
  vpc_cidr_block = "10.0.0.0/16"
  Private_subnet = ["10.0.10.0/24", "10.0.20.0/24"]
  Public_subnet  = ["10.0.1.0/24", "10.0.2.0/24"]
  az             = ["ap-northeast-1a", "ap-northeast-1c"]
}
module "ec2" {
  source         = "./EC2"
  vpc            = module.vpc
  sg_public      = module.vpc.sg_public
  subnet_public  = module.vpc.subnet_public
  sg_private     = module.vpc.sg_private
  subnet_private = module.vpc.subnet_private
  az             = ["us-east-1a", "us-east-1b"]


}
