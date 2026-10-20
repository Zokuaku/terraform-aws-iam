# A break-glass IAM user. People sign in through IAM Identity Center; an IAM user exists only for
# when that is unavailable. On purpose, this module has NO access-key resource and NO console
# password: Terraform never creates or holds a credential for it. A person sets the console
# password and registers the MFA device by hand, once, and the credentials are kept offline.
# Permissions come only from the groups the user is put in.
resource "aws_iam_user" "this" {
  name                 = var.name
  path                 = var.path
  permissions_boundary = var.permissions_boundary_arn
  force_destroy        = false
  tags                 = var.tags
}

resource "aws_iam_user_group_membership" "this" {
  user   = aws_iam_user.this.name
  groups = var.groups
}
