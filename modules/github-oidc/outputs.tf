output "role_arn" {
  description = "The CI role's ARN - the value for role-to-assume in aws-actions/configure-aws-credentials."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "The CI role's name."
  value       = aws_iam_role.this.name
}

output "provider_arn" {
  description = "The ARN of GitHub's OIDC provider, to pass as existing_provider_arn to the next role."
  value       = local.provider_arn
}
