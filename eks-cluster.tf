
# add configuration to k8s provider to auth with the k8s cluster
provider "kubernetes" {
  host = data.aws_eks_cluster.myapp-cluster.endpoint
  token = data.aws_eks_cluster_auth.myapp-cluster.token
  client_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority[0].data)
}

data "aws_eks_cluster" "myapp-cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster" {
  name = module.eks.cluster_id
}


# the eks module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.20.4"
  # insert the 15 required variables here
  
  cluster_name = "myapp-eks-cluster" #cluster name already decided in the vpc module
  cluster_version = "1.22" # the cluster verison needed 

  subnet_ids = module.vpc.private_subnets # list of subnets which we wants to the worker nodes (private subnets) 
  vpc_id = module.vpc.vpc_id # the vpc in which our works will be running

  # some optional tags (for humans)
  tags = {
      environment = "development"
      application="myapp"
  }

  # Configure our worker nodes
  eks_managed_node_groups={
      instance_type="t2.micro"
      name="worker-group-1"
      asg_desired_capacity=3 #we want 3 worker nodes
  }

}
