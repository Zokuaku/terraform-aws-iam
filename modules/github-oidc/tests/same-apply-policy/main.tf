# A policy created in the same configuration as the CI role it is attached to: its ARN is unknown until apply.
resource "aws_iam_policy" "fixture" {
  name = "fixture"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "iam:ListRoleTags", Resource = "arn:aws:iam::123456789012:role/fixture" }]
  })
}

module "subject" {
  source = "../.."

  role_name           = "fixture-ci"
  role_description    = "Fixture."
  subjects            = ["repo:example-org/example-repo:pull_request"]
  managed_policy_arns = { fixture = aws_iam_policy.fixture.arn }
}

output "planned" {
  value = true
}
