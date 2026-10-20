# The account's password policy at the module's baseline, with a longer minimum length.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

module "password_policy" {
  source = "../.."

  minimum_password_length = 16
}

output "expire_passwords" {
  description = "Whether passwords expire under the policy."
  value       = module.password_policy.expire_passwords
}
