output "name" {
  description = "The user's name."
  value       = aws_iam_user.this.name
}

output "arn" {
  description = "The user's ARN."
  value       = aws_iam_user.this.arn
}
