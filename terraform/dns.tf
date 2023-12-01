resource "aws_route53_zone" "main" {
  name = "${local.name}.pietervincken.com"

  force_destroy = true
}

resource "aws_iam_policy" "external_dns_operator" {
  name        = "external_dns_operator"
  path        = "/"
  description = "Allow external dns operator to manage the hosted zones"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
            "${aws_route53_zone.main.arn}"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role" "external_dns_operator" {
  name = "external_dns_operator"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:external-dns:external-dns"
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "external_dns_operator" {
  name       = "external_dns_operator"
  roles      = [aws_iam_role.external_dns_operator.name]
  policy_arn = aws_iam_policy.external_dns_operator.arn
}

output "external_dns_operator_iam_role" {
  value = aws_iam_role.external_dns_operator.arn
}

output "hosted_zone_ns" {
  value = aws_route53_zone.main.name_servers
}

