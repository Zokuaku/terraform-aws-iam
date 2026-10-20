# terraform-aws-iam

Terraform modules for AWS Identity and Access Management. Each module is small, validates its
inputs, refuses the unsafe choices instead of documenting them, and is tested against a mocked
AWS provider, so the checks need no account and no credentials.

| Module | What it manages |
|---|---|
| [`account-password-policy`](modules/account-password-policy) | The account's IAM password policy, at a baseline it will not go below |
| [`role`](modules/role) | An IAM role that trusts only the principals it names, with managed policies and an optional permissions boundary |

## Use

```hcl
module "instance_role" {
  source = "github.com/Zokuaku/terraform-aws-iam//modules/role?ref=v0.1.0"

  name                = "app-instance"
  description         = "Assumed by the application's EC2 instances; read-only."
  trusted_services    = ["ec2.amazonaws.com"]
  managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}
```

Each module has a runnable example under `examples/`.

## What the modules refuse

The `role` module will not create a role nobody can assume, a role trusting a wildcard
principal, a role with `AdministratorAccess` attached, or a session longer than twelve hours.
The `account-password-policy` module will not go below a 14-character minimum, or let passwords
never expire. Each refusal is a variable validation with a test that proves it.

## How it is checked

Every pull request runs five checks on each module, defined once in
[`Zokuaku/shared-workflows`](https://github.com/Zokuaku/shared-workflows) and pinned here by
commit: `terraform fmt`, `terraform validate` (module and examples), TFLint with the AWS ruleset,
`terraform test` against a mocked provider, and a checkov security scan.

## Conventions

- Modules declare a **minimum** Terraform and provider version and no provider configuration;
  the caller pins exact versions and owns the lock file.
- Releases are tagged `vMAJOR.MINOR.PATCH`; each tag publishes a GitHub Release with its
  [changelog](CHANGELOG.md) section. Pin a tag in `?ref=`.

## Licence

[Apache-2.0](LICENSE).
