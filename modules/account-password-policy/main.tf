# The account's IAM password policy. There is one per account, so this module is used once per
# account, in the layer that owns account-wide settings.
resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = var.minimum_password_length
  password_reuse_prevention      = var.password_reuse_prevention
  max_password_age               = var.max_password_age
  require_symbols                = var.require_symbols
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_lowercase_characters   = var.require_lowercase_characters
  allow_users_to_change_password = var.allow_users_to_change_password
  hard_expiry                    = var.hard_expiry
}
