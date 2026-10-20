# GitHub Actions reaches AWS with a short-lived token instead of a stored access key: the workflow
# presents GitHub's OIDC token, and this role trusts it only for the audience sts.amazonaws.com and
# the exact subjects given. No thumbprint is configured: for GitHub, AWS validates the provider
# against its own trusted certificate authorities.
locals {
  issuer       = "token.actions.githubusercontent.com"
  provider_arn = var.create_provider ? aws_iam_openid_connect_provider.github[0].arn : var.existing_provider_arn
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_provider ? 1 : 0

  url            = "https://${local.issuer}"
  client_id_list = ["sts.amazonaws.com"]
  tags           = var.tags
}

resource "aws_iam_role" "this" {
  name                 = var.role_name
  description          = var.role_description
  max_session_duration = var.max_session_duration
  permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "TrustGitHubWorkflows"
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = local.provider_arn }
      Condition = {
        StringEquals = { "${local.issuer}:aud" = "sts.amazonaws.com" }
        StringLike   = { "${local.issuer}:sub" = sort(tolist(var.subjects)) }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.managed_policy_arns

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
