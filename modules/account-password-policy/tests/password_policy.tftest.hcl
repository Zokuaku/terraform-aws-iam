# Runs against a mocked AWS provider: no account, no credentials, nothing created.
mock_provider "aws" {}

run "defaults_meet_the_baseline" {
  command = apply

  assert {
    condition     = aws_iam_account_password_policy.this.minimum_password_length == 14
    error_message = "The default minimum length is not 14."
  }

  assert {
    condition     = aws_iam_account_password_policy.this.password_reuse_prevention == 24
    error_message = "The default reuse prevention is not 24."
  }

  assert {
    condition     = aws_iam_account_password_policy.this.max_password_age == 90
    error_message = "The default maximum age is not 90 days."
  }

  assert {
    condition = alltrue([
      aws_iam_account_password_policy.this.require_symbols,
      aws_iam_account_password_policy.this.require_numbers,
      aws_iam_account_password_policy.this.require_uppercase_characters,
      aws_iam_account_password_policy.this.require_lowercase_characters,
    ])
    error_message = "Every character class should be required by default."
  }
}

run "a_short_minimum_length_is_refused" {
  command = plan

  variables {
    minimum_password_length = 8
  }

  expect_failures = [var.minimum_password_length]
}

run "passwords_that_never_expire_are_refused" {
  command = plan

  variables {
    max_password_age = 0
  }

  expect_failures = [var.max_password_age]
}

run "a_longer_minimum_is_accepted" {
  command = apply

  variables {
    minimum_password_length = 20
  }

  assert {
    condition     = output.minimum_password_length == 20
    error_message = "A stricter minimum length was not applied."
  }
}
