output "name" {
  description = "The role's name."
  value       = aws_iam_role.this.name
}

output "arn" {
  description = "The role's ARN."
  value       = aws_iam_role.this.arn
}

output "trust_policy" {
  description = "The role's trust policy, as JSON."
  value       = aws_iam_role.this.assume_role_policy
}
