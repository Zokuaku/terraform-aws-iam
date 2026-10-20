# Runs against a mocked AWS provider: no account, no credentials, nothing created.
mock_provider "aws" {}

variables {
  name = "platform-readers"
}

run "a_group_requires_mfa_by_default" {
  command = apply

  variables {
    managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  }

  assert {
    condition     = length(aws_iam_group_policy.require_mfa) == 1
    error_message = "The MFA requirement is not on by default."
  }

  assert {
    condition = anytrue([
      for s in jsondecode(aws_iam_group_policy.require_mfa[0].policy).Statement :
      s.Effect == "Deny" && s.Condition.BoolIfExists["aws:MultiFactorAuthPresent"] == "false"
    ])
    error_message = "The MFA policy does not deny actions when MFA is absent."
  }

  assert {
    condition     = keys(aws_iam_group_policy_attachment.this) == ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    error_message = "The managed policy was not attached exactly once."
  }
}

run "administrator_access_is_refused_unless_asked_for" {
  command = plan

  variables {
    managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }

  expect_failures = [var.managed_policy_arns]
}

run "a_break_glass_group_may_hold_administrator_access" {
  command = apply

  variables {
    name                       = "break-glass"
    managed_policy_arns        = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    allow_administrator_access = true
  }

  assert {
    condition     = length(aws_iam_group_policy_attachment.this) == 1 && length(aws_iam_group_policy.require_mfa) == 1
    error_message = "A break-glass group should hold AdministratorAccess and still require MFA."
  }
}
