output "name" {
  description = "The policy's name."
  value       = aws_iam_policy.this.name
}

output "arn" {
  description = "The policy's ARN, to attach to a group or a role."
  value       = aws_iam_policy.this.arn
}
