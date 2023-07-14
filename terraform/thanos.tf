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
      values = [
        "system:serviceaccount:monitoring:prometheus-k8s",
        "system:serviceaccount:monitoring:thanos-query",
        "system:serviceaccount:monitoring:thanos-store"
      ]
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

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"
}
