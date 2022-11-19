module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.30.3"

  cluster_name    = local.name
  cluster_version = "1.24"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3a.medium"]
      #   capacity_type  = "SPOT" # TODO cool addition!
    }
  }
}

output "eks_name" {
  value = local.name
}
