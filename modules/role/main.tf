# The trust policy is built here, from the inputs, rather than taken whole from the caller: every
# role made with this module trusts only principals it names, and a test can read the policy.
locals {
  trust_statements = concat(
    length(var.trusted_services) == 0 ? [] : [{
      Sid       = "TrustServices"
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = sort(tolist(var.trusted_services)) }
    }],
    length(var.trusted_role_arns) == 0 ? [] : [{
      Sid       = "TrustRoles"
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = sort(tolist(var.trusted_role_arns)) }
    }],
  )
}

resource "aws_iam_role" "this" {
  name                 = var.name
  description          = var.description
  path                 = var.path
  max_session_duration = var.max_session_duration
  permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.trust_statements
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.managed_policy_arns

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
