resource "aws_ecr_repository" "this" {
  name                 = "renovate-talk-java-demo-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}

resource "aws_iam_policy" "kaniko" {
  name        = "kaniko_ecr_access"
  path        = "/"
  description = "Allow Kaniko to push images"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ecr:CompleteLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:InitiateLayerUpload",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage"
          ],
          "Resource" : "${aws_ecr_repository.this.arn}"
        },
        {
          "Effect" : "Allow",
          "Action" : "ecr:GetAuthorizationToken",
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role" "kaniko" {
  name = "kaniko"

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
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:*:tekline"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "kaniko" {
  name       = "kaniko_ecr_access"
  roles      = [aws_iam_role.kaniko.name]
  policy_arn = aws_iam_policy.kaniko.arn
}

output "tekline_iam_role" {
  value = aws_iam_role.kaniko.arn
}

output "ecr_repo_url" {
  value = aws_ecr_repository.this.repository_url
}