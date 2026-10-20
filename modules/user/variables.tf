variable "name" {
  description = "The user's name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,64}$", var.name))
    error_message = "name must be 1-64 characters: letters, digits and + = , . @ _ -."
  }
}

variable "path" {
  description = "The IAM path the user lives under."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/([A-Za-z0-9+=,.@_-]+/)*$", var.path))
    error_message = "path must start and end with '/'."
  }
}

variable "groups" {
  description = "Groups the user belongs to. Permissions come only from groups, never attached to the user."
  type        = set(string)

  validation {
    condition     = length(var.groups) > 0
    error_message = "A user with no group has no permissions and no MFA requirement; name at least one group."
  }
}

variable "permissions_boundary_arn" {
  description = "A permissions boundary to set on the user, or null for none."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for the user."
  type        = map(string)
  default     = {}
}
