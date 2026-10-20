resource "aws_iam_group" "this" {
  name = var.name
  path = var.path
}

resource "aws_iam_group_policy_attachment" "this" {
  for_each = var.managed_policy_arns

  group      = aws_iam_group.this.name
  policy_arn = each.value
}

# Members may only look at the password policy, change their own password and set up their own
# MFA device until they have signed in with MFA; everything else is denied. This follows the
# policy AWS documents for "allow MFA-authenticated IAM users to manage their own credentials".
resource "aws_iam_group_policy" "require_mfa" {
  count = var.require_mfa ? 1 : 0

  name  = "require-mfa"
  group = aws_iam_group.this.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowViewAccountInfo"
        Effect   = "Allow"
        Action   = ["iam:GetAccountPasswordPolicy", "iam:ListVirtualMFADevices"]
        Resource = "*"
      },
      {
        Sid      = "AllowManageOwnPasswordAndMfa"
        Effect   = "Allow"
        Action   = ["iam:ChangePassword", "iam:GetUser", "iam:DeactivateMFADevice", "iam:EnableMFADevice", "iam:ListMFADevices", "iam:ResyncMFADevice"]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid      = "AllowCreateOwnVirtualMfaDevice"
        Effect   = "Allow"
        Action   = ["iam:CreateVirtualMFADevice"]
        Resource = "arn:aws:iam::*:mfa/*"
      },
      {
        Sid       = "DenyAllExceptListedIfNoMfa"
        Effect    = "Deny"
        NotAction = ["iam:CreateVirtualMFADevice", "iam:EnableMFADevice", "iam:GetUser", "iam:ListMFADevices", "iam:ListVirtualMFADevices", "iam:ResyncMFADevice", "iam:ChangePassword", "iam:GetAccountPasswordPolicy", "sts:GetSessionToken"]
        Resource  = "*"
        Condition = { BoolIfExists = { "aws:MultiFactorAuthPresent" = "false" } }
      },
    ]
  })
}
