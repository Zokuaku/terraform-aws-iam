# Two CI roles for one repository: a read-only role any pull request may use for `terraform plan`,
# and an apply role only the production environment's approved deployments may use.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

module "ci_plan" {
  source = "../.."

  role_name           = "ci-plan"
  role_description    = "terraform plan for pull requests; read-only."
  subjects            = ["repo:example-org/infrastructure-live:pull_request"]
  managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}

module "ci_apply" {
  source = "../.."

  create_provider       = false
  existing_provider_arn = module.ci_plan.provider_arn

  role_name                = "ci-apply-production"
  role_description         = "terraform apply from the production environment, after its required review."
  subjects                 = ["repo:example-org/infrastructure-live:environment:production"]
  permissions_boundary_arn = "arn:aws:iam::123456789012:policy/ci-boundary"
}

output "plan_role_arn" {
  description = "role-to-assume for plan jobs."
  value       = module.ci_plan.role_arn
}

output "apply_role_arn" {
  description = "role-to-assume for apply jobs."
  value       = module.ci_apply.role_arn
}
