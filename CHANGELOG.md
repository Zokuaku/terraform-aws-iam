# Changelog

All notable changes. Versions follow [semantic versioning](https://semver.org/).

## v0.2.0 - 2026-10-20

The identity model: people through IAM Identity Center (next release), CI through GitHub OIDC,
IAM users for break-glass only.

- `github-oidc`: GitHub's OIDC provider (no thumbprint - AWS validates GitHub against its own
  trusted certificate authorities) and a CI role trusting only the audience `sts.amazonaws.com`
  and the exact subjects given. Refuses wildcard repositories, every-branch subjects and
  `AdministratorAccess`. One provider per account: later roles pass `existing_provider_arn`.
- `policy`: a customer-managed policy from a document. Refuses a document that is not a policy
  and any statement allowing every action.
- `group`: a group with managed policies and, by default, a policy that denies everything but MFA
  set-up until the member signs in with MFA. `AdministratorAccess` only with
  `allow_administrator_access`.
- `user`: a break-glass user - no access key and no password resource, permissions only from its
  groups, never force-destroyed.
- Checks now cover six modules.

## v0.1.0 - 2026-10-20

First release.

- `account-password-policy`: the account's IAM password policy. Defaults: 14 characters,
  every character class, 24 remembered passwords, 90-day expiry. Refuses a minimum below 14
  and passwords that never expire.
- `role`: an IAM role whose trust policy is built from the services and role ARNs it is given.
  Refuses a role nobody can assume, wildcard principals, `AdministratorAccess`, and sessions
  over twelve hours. Managed policies and a permissions boundary are optional.
- Tests for both against a mocked AWS provider; checks from `Zokuaku/shared-workflows` v0.2.0.
