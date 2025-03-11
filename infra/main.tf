terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.61.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
  #access_key = var.AWS_ACCESS_KEY_ID
  #secret_key = var.AWS_SECRET_ACCESS_KEY
}
module "vpc" {
  source         = "./vpc"
  vpc_cidr_block = "10.0.0.0/16"
  Private_subnet = ["10.0.10.0/24", "10.0.20.0/24"]
  Public_subnet  = ["10.0.1.0/24", "10.0.2.0/24"]
  az             = ["eu-central-1b", "eu-central-1c"]
}
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "private-example"
  #repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
  tags = {
    Terraform   = "true"
    Environment = "local"
  }
}
module "ecs" {
  source                 = "./ECS"
  subnet_public          = module.vpc.subnet_public
  vpc_security_group_ids = module.vpc.sg_public
  vpc_id                 = module.vpc.vpc_id
}

# module "ec2" {
#   source         = "./EC2"
#   vpc            = module.vpc
#   sg_public      = module.vpc.sg_public
#   subnet_public  = module.vpc.subnet_public
#   sg_private     = module.vpc.sg_private
#   subnet_private = module.vpc.subnet_private
#   az             = ["ap-southeast-1a", "ap-southeast-1c"]


# }
