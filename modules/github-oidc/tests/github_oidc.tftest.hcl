# Runs against a mocked AWS provider: no account, no credentials, nothing created.
# 123456789012 is the documentation placeholder for an AWS account number.
mock_provider "aws" {}

variables {
  role_name        = "ci-plan"
  role_description = "Terraform plan from the main branch of one repository."
  subjects         = ["repo:example-org/infrastructure-live:ref:refs/heads/main"]
}

run "the_role_trusts_github_for_exactly_its_subjects" {
  command = apply

  assert {
    condition     = length(aws_iam_openid_connect_provider.github) == 1
    error_message = "The OIDC provider is not created by default."
  }

  assert {
    condition     = aws_iam_openid_connect_provider.github[0].url == "https://token.actions.githubusercontent.com"
    error_message = "The provider does not point at GitHub's issuer."
  }

  assert {
    condition     = toset(aws_iam_openid_connect_provider.github[0].client_id_list) == toset(["sts.amazonaws.com"])
    error_message = "The provider's audience is not exactly sts.amazonaws.com."
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:aud"] == "sts.amazonaws.com"
    error_message = "The trust policy does not pin the audience."
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Condition.StringLike["token.actions.githubusercontent.com:sub"] == ["repo:example-org/infrastructure-live:ref:refs/heads/main"]
    error_message = "The trust policy does not name exactly the given subject."
  }
}

run "a_second_role_reuses_the_existing_provider" {
  command = apply

  variables {
    create_provider       = false
    existing_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  }

  assert {
    condition     = length(aws_iam_openid_connect_provider.github) == 0
    error_message = "A second provider was created."
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Principal.Federated == "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
    error_message = "The role does not trust the existing provider."
  }
}

run "no_provider_at_all_is_refused" {
  command = plan

  variables {
    create_provider = false
  }

  expect_failures = [var.existing_provider_arn]
}

run "a_wildcard_repository_is_refused" {
  command = plan

  variables {
    subjects = ["repo:example-org/*:ref:refs/heads/main"]
  }

  expect_failures = [var.subjects]
}

run "every_branch_of_a_repository_is_refused" {
  command = plan

  variables {
    subjects = ["repo:example-org/infrastructure-live:*"]
  }

  expect_failures = [var.subjects]
}

run "administrator_access_is_refused" {
  command = plan

  variables {
    managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }

  expect_failures = [var.managed_policy_arns]
}
