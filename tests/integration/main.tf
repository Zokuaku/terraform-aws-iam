# Integration fixture: the modules composed the way an account layer would use them, applied to a
# REAL account by identity.tftest.hcl and destroyed again by `terraform test` when it finishes.
# Everything it creates is IAM, which is free. Credentials come from the environment
# (AWS_PROFILE, or the CI role) - no provider configuration here.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

variable "name_prefix" {
  description = "Prefix for every name the test creates, so a leftover is easy to find."
  type        = string
  default     = "itest"
}

locals {
  tags = {
    purpose      = "integration-test"
    "managed-by" = "terraform-test"
  }
}

module "password_policy" {
  source = "../../modules/account-password-policy"
}

data "aws_iam_policy_document" "read_role_tags" {
  statement {
    sid       = "ReadRoleTags"
    actions   = ["iam:ListRoleTags"]
    resources = ["arn:aws:iam::*:role/${var.name_prefix}-*"]
  }
}

module "policy" {
  source = "../../modules/policy"

  name        = "${var.name_prefix}-read-role-tags"
  description = "Integration test: one read-only IAM action."
  policy_json = data.aws_iam_policy_document.read_role_tags.json
  tags        = local.tags
}

module "group" {
  source = "../../modules/group"

  name                = "${var.name_prefix}-operators"
  managed_policy_arns = { read_role_tags = module.policy.arn }
}

module "user" {
  source = "../../modules/user"

  name   = "${var.name_prefix}-breakglass"
  groups = [module.group.name]
  tags   = local.tags
}

module "role" {
  source = "../../modules/role"

  name                 = "${var.name_prefix}-app-instance"
  description          = "Integration test: an EC2 service role."
  trusted_services     = ["ec2.amazonaws.com"]
  managed_policy_arns  = { read_role_tags = module.policy.arn }
  max_session_duration = 7200
  tags                 = local.tags
}

# The subject names a repository that does not exist: nothing can assume this role, even during
# the minute it exists.
module "ci" {
  source = "../../modules/github-oidc"

  role_name           = "${var.name_prefix}-ci-plan"
  role_description    = "Integration test: a plan-only CI role."
  subjects            = ["repo:example-org/integration-test:pull_request"]
  managed_policy_arns = { read_only = "arn:aws:iam::aws:policy/ReadOnlyAccess" }
  tags                = local.tags
}

output "policy_arn" {
  value = module.policy.arn
}

output "group_name" {
  value = module.group.name
}

output "user_name" {
  value = module.user.name
}

output "role_name" {
  value = module.role.name
}

output "ci_role_name" {
  value = module.ci.role_name
}
