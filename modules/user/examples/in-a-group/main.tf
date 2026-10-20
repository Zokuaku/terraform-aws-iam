# One user in an existing group. For the full break-glass pair see ../../../group/examples/break-glass.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

module "user" {
  source = "../.."

  name   = "break-glass-2"
  groups = ["break-glass"]
}

output "user_arn" {
  description = "The user's ARN."
  value       = module.user.arn
}
