module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.20.0"

  cluster_name    = local.name
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  cloudwatch_log_group_retention_in_days = 14

  # TODO investigate
  # cluster_addons = [
  #   "aws-ebs-csi-driver"
  # ]

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3a.medium"]
      #   capacity_type  = "SPOT" # TODO cool addition!
    }
  }

  tags = data.aws_default_tags.default.tags
}

data "aws_default_tags" "default" {}


output "eks_name" {
  value = local.name
}
