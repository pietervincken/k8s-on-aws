resource "aws_iam_policy" "external_secrets_operator" {
  name        = "external_secrets_operator"
  path        = "/"
  description = "Allow external secrets operator to load all secrets"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role" "external_secrets_operator" {
  name = "external_secrets_operator"

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
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:external-secrets:secret-store"
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "external_secrets_operator" {
  name       = "external_secrets_operator"
  roles      = [aws_iam_role.external_secrets_operator.name]
  policy_arn = aws_iam_policy.external_secrets_operator.arn
}

output "external_secrets_operator_iam_role" {
  value = aws_iam_role.external_secrets_operator.arn
}
