module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.30.3"

  cluster_name    = local.name
  cluster_version = "1.24"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = toset(data.aws_subnets.this.ids)

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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

output "eks_name" {
  value = local.name
}
