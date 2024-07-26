module "cert_manager_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.41.0"

  role_name                     = "${local.name}-cert-manager"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = [aws_route53_zone.main.arn]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }
}

output "cert_manager_iam_role" {
  value = module.cert_manager_irsa_role.iam_role_arn
}

module "cluster_autoscaler_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.41.0"

  role_name                        = "${local.name}-cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:autoscaler-aws-cluster-autoscaler"]
    }
  }
}

output "cluster_autoscaler_iam_role" {
  value = module.cluster_autoscaler_irsa_role.iam_role_arn
}

# module "external_dns_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                     = "external-dns"
#   attach_external_dns_policy    = true
#   external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/IClearlyMadeThisUp"]

#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:external-dns"]
#     }
#   }

#   tags = local.tags
# }

# module "external_secrets_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                             = "external-secrets"
#   attach_external_secrets_policy        = true
#   external_secrets_ssm_parameter_arns   = ["arn:aws:ssm:*:*:parameter/foo"]
#   external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:*:*:secret:bar"]

#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["default:kubernetes-external-secrets"]
#     }
#   }

#   tags = local.tags
# }
