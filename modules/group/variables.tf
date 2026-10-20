variable "name" {
  description = "The group's name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,128}$", var.name))
    error_message = "name must be 1-128 characters: letters, digits and + = , . @ _ -."
  }
}

variable "path" {
  description = "The IAM path the group lives under."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/([A-Za-z0-9+=,.@_-]+/)*$", var.path))
    error_message = "path must start and end with '/'."
  }
}

variable "managed_policy_arns" {
  description = "Managed policies attached to the group."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for a in var.managed_policy_arns : can(regex("^arn:aws[a-z-]*:iam::([0-9]{12}|aws):policy/", a))])
    error_message = "Each entry must be a managed policy ARN."
  }

  validation {
    condition     = var.allow_administrator_access || !anytrue([for a in var.managed_policy_arns : endswith(a, ":policy/AdministratorAccess")])
    error_message = "AdministratorAccess is attached only when allow_administrator_access is true - a break-glass group, on purpose."
  }
}

variable "allow_administrator_access" {
  description = "Set true only for the break-glass group, to allow AdministratorAccess among the managed policies."
  type        = bool
  default     = false
}

variable "require_mfa" {
  description = "Deny every action except setting up MFA until the member has signed in with MFA."
  type        = bool
  default     = true
}
