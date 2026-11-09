# Integration test against a REAL AWS account: apply the fixture, read everything back through
# separate data sources, assert, and let `terraform test` destroy it all. IAM only - no cost.
#
#   AWS_PROFILE=<profile> terraform -chdir=tests/integration test
#
# Not run by the pull-request checks (they need no account); see the README.

run "apply" {
  command = apply

  assert {
    condition     = module.password_policy.minimum_password_length == 14 && module.password_policy.expire_passwords
    error_message = "The account password policy is not at the baseline (14 characters, passwords expire)."
  }

  assert {
    condition     = output.user_name == "itest-breakglass" && output.role_name == "itest-app-instance"
    error_message = "The fixture did not create the expected names."
  }
}

run "read_back" {
  command = apply # data sources only: nothing is created

  module {
    source = "./verify"
  }

  variables {
    policy_arn   = run.apply.policy_arn
    group_name   = run.apply.group_name
    user_name    = run.apply.user_name
    role_name    = run.apply.role_name
    ci_role_name = run.apply.ci_role_name
  }

  assert {
    condition     = output.policy_actions == ["iam:ListRoleTags"]
    error_message = "The policy in AWS does not hold exactly the one action it was given."
  }

  assert {
    condition     = output.group_members == ["itest-breakglass"]
    error_message = "The break-glass user is not the group's only member."
  }

  assert {
    condition     = output.user_access_key_count == 0
    error_message = "The break-glass user has an access key; the module must never create one."
  }

  assert {
    condition     = output.user_permissions_boundary == ""
    error_message = "The user carries a permissions boundary it was not given."
  }

  assert {
    condition     = output.role_trusted_services == ["ec2.amazonaws.com"]
    error_message = "The service role trusts something other than exactly ec2.amazonaws.com."
  }

  assert {
    condition     = output.role_max_session_duration == 7200
    error_message = "The role's maximum session duration is not the value given."
  }

  assert {
    condition     = output.ci_trust_action == ["sts:AssumeRoleWithWebIdentity"]
    error_message = "The CI role's trust does not allow only web-identity assumption."
  }

  assert {
    condition     = output.ci_audience == ["sts.amazonaws.com"]
    error_message = "The CI role does not pin the audience to sts.amazonaws.com."
  }

  assert {
    condition     = output.ci_subjects == ["repo:example-org/integration-test:pull_request"]
    error_message = "The CI role trusts subjects other than exactly the one given."
  }

  assert {
    condition     = output.ci_federated_principal == [output.oidc_provider_arn]
    error_message = "The CI role does not trust GitHub's OIDC provider."
  }

  assert {
    condition     = length(output.oidc_client_ids) == 1 && contains(output.oidc_client_ids, "sts.amazonaws.com")
    error_message = "GitHub's OIDC provider does not list exactly the sts.amazonaws.com client."
  }
}
