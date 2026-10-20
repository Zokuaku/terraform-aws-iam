# Changelog

All notable changes. Versions follow [semantic versioning](https://semver.org/).

## v0.1.0 - 2026-10-20

First release.

- `account-password-policy`: the account's IAM password policy. Defaults: 14 characters,
  every character class, 24 remembered passwords, 90-day expiry. Refuses a minimum below 14
  and passwords that never expire.
- `role`: an IAM role whose trust policy is built from the services and role ARNs it is given.
  Refuses a role nobody can assume, wildcard principals, `AdministratorAccess`, and sessions
  over twelve hours. Managed policies and a permissions boundary are optional.
- Tests for both against a mocked AWS provider; checks from `Zokuaku/shared-workflows` v0.2.0.
