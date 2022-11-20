# module "cert_manager_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                     = "cert-manager"
#   attach_cert_manager_policy    = true
#   cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/IClearlyMadeThisUp"]

#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:cert-manager"]
#     }
#   }

#   tags = local.tags
# }

module "cluster_autoscaler_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                        = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_id]

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

# module "ebs_csi_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name             = "ebs-csi"
#   attach_ebs_csi_policy = true

#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
#     }
#   }

#   tags = local.tags
# }

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
