output "name" {
  description = "The group's name."
  value       = aws_iam_group.this.name
}

output "arn" {
  description = "The group's ARN."
  value       = aws_iam_group.this.arn
}
