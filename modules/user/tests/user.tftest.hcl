# Runs against a mocked AWS provider: no account, no credentials, nothing created.
mock_provider "aws" {}

run "a_user_is_created_in_its_groups" {
  command = apply

  variables {
    name   = "break-glass-1"
    groups = ["break-glass"]
  }

  assert {
    condition     = aws_iam_user_group_membership.this.groups == toset(["break-glass"])
    error_message = "The user is not in exactly the named group."
  }

  assert {
    condition     = aws_iam_user.this.force_destroy == false
    error_message = "A user must never be force-destroyed with credentials still on it."
  }
}

run "a_user_without_a_group_is_refused" {
  command = plan

  variables {
    name   = "break-glass-1"
    groups = []
  }

  expect_failures = [var.groups]
}
