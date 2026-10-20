output "expire_passwords" {
  description = "Whether passwords expire under this policy."
  value       = aws_iam_account_password_policy.this.expire_passwords
}

output "minimum_password_length" {
  description = "The minimum password length in force."
  value       = aws_iam_account_password_policy.this.minimum_password_length
}
