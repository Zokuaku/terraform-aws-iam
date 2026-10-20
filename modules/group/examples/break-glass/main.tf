# The break-glass pair: a group that holds AdministratorAccess and requires MFA, and the one
# emergency user in it. People sign in through IAM Identity Center; this is for when that is down.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

module "break_glass_group" {
  source = "../.."

  name                       = "break-glass"
  managed_policy_arns        = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  allow_administrator_access = true
}

module "break_glass_user" {
  source = "../../../user"

  name   = "break-glass-1"
  groups = [module.break_glass_group.name]
}

output "break_glass_user" {
  description = "The emergency user's name. Its console password and MFA device are set by a person, never by Terraform."
  value       = module.break_glass_user.name
}
