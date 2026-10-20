# Runs against a mocked AWS provider: no account, no credentials, nothing created.
mock_provider "aws" {}

variables {
  name        = "read-build-artifacts"
  description = "Read the build artifacts bucket."
}

run "a_scoped_policy_is_created" {
  command = apply

  variables {
    policy_json = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::build-artifacts", "arn:aws:s3:::build-artifacts/*"]
      }]
    })
  }

  assert {
    condition     = jsondecode(aws_iam_policy.this.policy).Statement[0].Action == ["s3:GetObject", "s3:ListBucket"]
    error_message = "The policy document was not passed through unchanged."
  }
}

run "allowing_every_action_is_refused" {
  command = plan

  variables {
    policy_json = jsonencode({
      Version   = "2012-10-17"
      Statement = [{ Effect = "Allow", Action = "*", Resource = "*" }]
    })
  }

  expect_failures = [var.policy_json]
}

run "a_document_that_is_not_a_policy_is_refused" {
  command = plan

  variables {
    policy_json = "{\"not\": \"a policy\"}"
  }

  expect_failures = [var.policy_json]
}

run "a_deny_on_every_action_is_allowed" {
  command = apply

  variables {
    policy_json = jsonencode({
      Version   = "2012-10-17"
      Statement = [{ Effect = "Deny", Action = "*", Resource = "*", Condition = { Bool = { "aws:SecureTransport" = "false" } } }]
    })
  }

  assert {
    condition     = jsondecode(aws_iam_policy.this.policy).Statement[0].Effect == "Deny"
    error_message = "A Deny on every action is a guardrail and should be accepted."
  }
}
