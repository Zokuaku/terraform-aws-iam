# Runs against a mocked AWS provider: no account, no credentials, nothing created.
# 123456789012 is the documentation placeholder for an AWS account number.
mock_provider "aws" {}

variables {
  name        = "ci-read-only"
  description = "Read-only access for the CI pipeline."
}

run "a_service_role_trusts_only_its_service" {
  command = apply

  variables {
    trusted_services    = ["ec2.amazonaws.com"]
    managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  }

  assert {
    condition     = length(jsondecode(aws_iam_role.this.assume_role_policy).Statement) == 1
    error_message = "A service-only role should have exactly one trust statement."
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Principal.Service == ["ec2.amazonaws.com"]
    error_message = "The trust statement does not name exactly the trusted service."
  }

  assert {
    condition     = keys(aws_iam_role_policy_attachment.this) == ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    error_message = "The managed policy was not attached exactly once."
  }

  assert {
    condition     = aws_iam_role.this.max_session_duration == 3600
    error_message = "The default session length is not one hour."
  }
}

run "a_role_can_trust_another_role" {
  command = apply

  variables {
    trusted_role_arns = ["arn:aws:iam::123456789012:role/deployer"]
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Principal.AWS == ["arn:aws:iam::123456789012:role/deployer"]
    error_message = "The trust statement does not name exactly the trusted role."
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.this) == 0
    error_message = "No policy should be attached when none is given."
  }
}

run "a_role_nobody_can_assume_is_refused" {
  command = plan

  expect_failures = [var.trusted_services]
}

run "a_wildcard_principal_is_refused" {
  command = plan

  variables {
    trusted_role_arns = ["*"]
  }

  expect_failures = [var.trusted_role_arns]
}

run "administrator_access_is_refused" {
  command = plan

  variables {
    trusted_services    = ["ec2.amazonaws.com"]
    managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }

  expect_failures = [var.managed_policy_arns]
}

run "a_session_longer_than_twelve_hours_is_refused" {
  command = plan

  variables {
    trusted_services     = ["ec2.amazonaws.com"]
    max_session_duration = 86400
  }

  expect_failures = [var.max_session_duration]
}
