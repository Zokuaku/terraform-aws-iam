# A role an EC2 instance can assume, with read-only access, under a permissions boundary.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

module "instance_role" {
  source = "../.."

  name                     = "app-instance"
  description              = "Assumed by the application's EC2 instances; read-only."
  trusted_services         = ["ec2.amazonaws.com"]
  managed_policy_arns      = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  permissions_boundary_arn = "arn:aws:iam::123456789012:policy/workload-boundary"

  tags = {
    owner = "platform"
  }
}

output "role_arn" {
  description = "The ARN of the role."
  value       = module.instance_role.arn
}
