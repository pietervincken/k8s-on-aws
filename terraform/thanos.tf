resource "aws_s3_bucket" "thanos" {
  bucket = "${local.name}-thanos"

  force_destroy = true //TODO for demo purposes only!
}

output "thanos_bucket" {
  value = aws_s3_bucket.thanos.bucket
}

data "aws_iam_policy_document" "thanos" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.thanos.arn,
      "${aws_s3_bucket.thanos.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "thanos_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test = "StringEquals"

      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:monitoring:thanos"]
    }

    condition {
      test = "StringEquals"

      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "thanos" {
  name               = "${local.name}-thanos"
  assume_role_policy = data.aws_iam_policy_document.thanos_assume.json
}

resource "aws_iam_policy" "thanos" {
  name   = "${local.name}-thanos"
  policy = data.aws_iam_policy_document.thanos.json
}

resource "aws_iam_role_policy_attachment" "thanos" {
  role       = aws_iam_role.thanos.name
  policy_arn = aws_iam_policy.thanos.arn
}
