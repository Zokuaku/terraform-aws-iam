variable "create_provider" {
  description = "Create GitHub's OIDC identity provider. There is one per account: set false and pass existing_provider_arn for every role after the first."
  type        = bool
  default     = true
}

variable "existing_provider_arn" {
  description = "The ARN of GitHub's OIDC provider when create_provider is false."
  type        = string
  default     = null

  validation {
    condition     = var.create_provider || try(can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:oidc-provider/token\\.actions\\.githubusercontent\\.com$", var.existing_provider_arn)), false)
    error_message = "When create_provider is false, existing_provider_arn must be the ARN of GitHub's OIDC provider."
  }
}

variable "role_name" {
  description = "The CI role's name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,64}$", var.role_name))
    error_message = "role_name must be 1-64 characters: letters, digits and + = , . @ _ -."
  }
}

variable "role_description" {
  description = "What the CI role is for."
  type        = string
}

variable "subjects" {
  description = <<-EOT
    The GitHub workflow subjects allowed to assume the role, e.g.
    "repo:<owner>/<repo>:ref:refs/heads/main" or "repo:<owner>/<repo>:environment:production".
    The owner and the repository are always named in full.
  EOT
  type        = set(string)

  validation {
    condition     = length(var.subjects) > 0
    error_message = "Name at least one subject; a role no workflow can assume is a mistake."
  }

  validation {
    condition     = alltrue([for s in var.subjects : can(regex("^repo:[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+:[^*].*$", s))])
    error_message = "Each subject names its owner and repository in full (no wildcard), then what it trusts: ref, environment or pull_request."
  }

  validation {
    condition     = !anytrue([for s in var.subjects : endswith(s, ":*") || s == "*"])
    error_message = "A subject ending in ':*' trusts every branch, tag and pull request of the repository; name what the role is for."
  }
}

variable "managed_policy_arns" {
  description = "Managed policies attached to the CI role."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for a in var.managed_policy_arns : can(regex("^arn:aws[a-z-]*:iam::([0-9]{12}|aws):policy/", a))])
    error_message = "Each entry must be a managed policy ARN."
  }

  validation {
    condition     = !anytrue([for a in var.managed_policy_arns : endswith(a, ":policy/AdministratorAccess")])
    error_message = "AdministratorAccess is never given to a CI role; grant what the pipeline deploys."
  }
}

variable "permissions_boundary_arn" {
  description = "A permissions boundary to set on the role, or null for none."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session length in seconds, from 3600 (one hour) to 43200 (twelve hours)."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "tags" {
  description = "Tags for the provider and the role."
  type        = map(string)
  default     = {}
}
