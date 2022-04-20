terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-3"
}

variable "vpc_cidr_block" {}
variable "private_subnets_cidr_blocks" {}
variable "public_subnets_cidr_blocks" {}


# get the available zones available
data "aws_availability_zones" "azs" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"
  # insert the 23 required variables here
  
  # Optional
  name = "myapp-eks-vpc"
  cidr=var.vpc_cidr_block
  private_subnets=var.private_subnets_cidr_blocks
  public_subnets=var.public_subnets_cidr_blocks
  azs=data.aws_availability_zones.azs.names

  enable_nat_gateway=true
  single_nat_gateway=true
  enable_dns_hostnames=true
 

  # To tell K8S which VPC to use in the cluster (because we can have multiple vpc and subnets etc ...)
  tags = {
      "kubernetes.io/cluster/myapp-eks-cluster"="shared" 
  }

 # To tell K8S which public subnet to use in the cluster
  public_subnet_tags={
      "kubernetes.io/cluster/myapp-eks-cluster"="shared"
      "kubernetes.io/role/elb"=1
  }

 # To tell K8S which private subnet to use in the cluster
  private_subnet_tags={
      "kubernetes.io/cluster/myapp-eks-cluster"="shared"
      "kubernetes.io/role/internal-elb"=1
  }


}