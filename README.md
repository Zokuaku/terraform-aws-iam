# terraform-aws-iam

Terraform modules for AWS Identity and Access Management. Each module is small, validates its
inputs, refuses the unsafe choices instead of documenting them, and is tested against a mocked
AWS provider, so the checks need no account and no credentials.

| Module | What it manages |
|---|---|
| [`account-password-policy`](modules/account-password-policy) | The account's IAM password policy, at a baseline it will not go below |
| [`role`](modules/role) | An IAM role that trusts only the principals it names, with managed policies and an optional permissions boundary |
| [`github-oidc`](modules/github-oidc) | GitHub's OIDC identity provider and a CI role, so GitHub Actions reaches AWS with a short-lived token and no stored key |
| [`policy`](modules/policy) | A customer-managed policy from a policy document |
| [`group`](modules/group) | A group with managed policies that requires MFA before anything else is allowed |
| [`user`](modules/user) | A break-glass IAM user - no access key, no password, permissions only from its groups |

## Identity model

People sign in through **IAM Identity Center** (single sign-on with short-lived credentials);
its permission sets come in a later release. CI signs in through **GitHub OIDC** with no stored
key. **IAM users exist only for break-glass**, for when single sign-on is unavailable: the
[break-glass example](modules/group/examples/break-glass) puts one user in a group that holds
`AdministratorAccess` and requires MFA. Terraform never creates or holds a credential for it - a
person sets its console password and MFA device once, and they are kept offline.

## Use

```hcl
module "instance_role" {
  source = "github.com/Zokuaku/terraform-aws-iam//modules/role?ref=v0.2.0"

  name                = "app-instance"
  description         = "Assumed by the application's EC2 instances; read-only."
  trusted_services    = ["ec2.amazonaws.com"]
  managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}
```

Each module has a runnable example under `examples/`.

## What the modules refuse

- `role` - a role nobody can assume, a wildcard principal, `AdministratorAccess`, a session
  longer than twelve hours.
- `github-oidc` - a subject that does not name its repository in full, one that trusts every
  branch of a repository (`:*`), `AdministratorAccess` on a CI role.
- `policy` - a document that is not a policy, a statement that allows every action (`"*"`).
- `group` - `AdministratorAccess`, unless `allow_administrator_access` says this is the
  break-glass group.
- `user` - a user in no group. It has no way to create an access key or a password at all.
- `account-password-policy` - a minimum below 14 characters, passwords that never expire.

Each refusal is a variable validation with a test that proves it. Two security-scan findings are
accepted on purpose, each in its module's `.checkov.yaml` with the reason: `AdministratorAccess` on
the break-glass group, and the existence of an IAM user at all.

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
