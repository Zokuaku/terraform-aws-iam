variable "name" {
  description = "The role's name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,64}$", var.name))
    error_message = "name must be 1-64 characters: letters, digits and + = , . @ _ -."
  }
}

variable "description" {
  description = "What the role is for. Shown in the console and in audit logs."
  type        = string
}

variable "path" {
  description = "The IAM path the role lives under."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/([A-Za-z0-9+=,.@_-]+/)*$", var.path))
    error_message = "path must start and end with '/'."
  }
}

variable "trusted_services" {
  description = "AWS service principals that may assume the role, for example ec2.amazonaws.com."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for s in var.trusted_services : can(regex("^[a-z0-9.-]+\\.amazonaws\\.com$", s))])
    error_message = "Each trusted service must be a service principal ending in .amazonaws.com."
  }

  validation {
    condition     = length(var.trusted_services) + length(var.trusted_role_arns) > 0
    error_message = "A role needs at least one trusted service or trusted role ARN - nobody could assume it otherwise."
  }
}

variable "trusted_role_arns" {
  description = "IAM role ARNs that may assume this role. Wildcards are refused: name each role."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for a in var.trusted_role_arns : can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:role/[A-Za-z0-9+=,.@_/-]+$", a))])
    error_message = "Each trusted role must be a full role ARN without wildcards."
  }
}

variable "managed_policy_arns" {
  description = "Managed policies to attach to the role."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for a in var.managed_policy_arns : can(regex("^arn:aws[a-z-]*:iam::([0-9]{12}|aws):policy/", a))])
    error_message = "Each entry must be a managed policy ARN."
  }

  validation {
    condition     = !anytrue([for a in var.managed_policy_arns : endswith(a, ":policy/AdministratorAccess")])
    error_message = "AdministratorAccess is not attached through this module; break-glass access is managed separately."
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
  description = "Tags for the role."
  type        = map(string)
  default     = {}
}
