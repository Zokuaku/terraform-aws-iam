# A customer-managed policy from a policy document, ready to attach to a group or a role.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

data "aws_iam_policy_document" "read_artifacts" {
  statement {
    sid       = "ReadBuildArtifacts"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::build-artifacts", "arn:aws:s3:::build-artifacts/*"]
  }
}

module "read_artifacts" {
  source = "../.."

  name        = "read-build-artifacts"
  description = "Read the build artifacts bucket."
  policy_json = data.aws_iam_policy_document.read_artifacts.json
}

output "policy_arn" {
  description = "The policy's ARN."
  value       = module.read_artifacts.arn
}
