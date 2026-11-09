# Reads back, through separate data sources, what the apply run created - so the assertions test
# what AWS holds, not what Terraform remembers writing. Creates nothing.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

variable "policy_arn" {
  type = string
}

variable "group_name" {
  type = string
}

variable "user_name" {
  type = string
}

variable "role_name" {
  type = string
}

variable "ci_role_name" {
  type = string
}

data "aws_iam_policy" "policy" {
  arn = var.policy_arn
}

data "aws_iam_group" "group" {
  group_name = var.group_name
}

data "aws_iam_user" "user" {
  user_name = var.user_name
}

data "aws_iam_access_keys" "user" {
  user = var.user_name
}

data "aws_iam_role" "role" {
  name = var.role_name
}

data "aws_iam_role" "ci" {
  name = var.ci_role_name
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# AWS returns a one-element list in a policy as a bare string; flatten([...]) reads both shapes.
locals {
  role_trust = jsondecode(data.aws_iam_role.role.assume_role_policy).Statement
  ci_trust   = jsondecode(data.aws_iam_role.ci.assume_role_policy).Statement
}

output "policy_actions" {
  value = flatten([for s in jsondecode(data.aws_iam_policy.policy.policy).Statement : flatten([s.Action])])
}

output "group_members" {
  value = [for u in data.aws_iam_group.group.users : u.user_name]
}

output "user_access_key_count" {
  value = length(data.aws_iam_access_keys.user.access_keys)
}

output "user_permissions_boundary" {
  value = data.aws_iam_user.user.permissions_boundary
}

output "role_trusted_services" {
  value = flatten([for s in local.role_trust : flatten([try(s.Principal.Service, [])])])
}

output "role_max_session_duration" {
  value = data.aws_iam_role.role.max_session_duration
}

output "ci_trust_action" {
  value = flatten([for s in local.ci_trust : flatten([s.Action])])
}

output "ci_audience" {
  value = flatten([for s in local.ci_trust : flatten([s.Condition.StringEquals["token.actions.githubusercontent.com:aud"]])])
}

output "ci_subjects" {
  value = flatten([for s in local.ci_trust : flatten([s.Condition.StringLike["token.actions.githubusercontent.com:sub"]])])
}

output "ci_federated_principal" {
  value = flatten([for s in local.ci_trust : flatten([s.Principal.Federated])])
}

output "oidc_provider_arn" {
  value = data.aws_iam_openid_connect_provider.github.arn
}

output "oidc_client_ids" {
  value = data.aws_iam_openid_connect_provider.github.client_id_list
}
