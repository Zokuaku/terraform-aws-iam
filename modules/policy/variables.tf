variable "name" {
  description = "The policy's name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,128}$", var.name))
    error_message = "name must be 1-128 characters: letters, digits and + = , . @ _ -."
  }
}

variable "description" {
  description = "What the policy grants and why. Shown in the console and in audit logs."
  type        = string
}

variable "path" {
  description = "The IAM path the policy lives under."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/([A-Za-z0-9+=,.@_-]+/)*$", var.path))
    error_message = "path must start and end with '/'."
  }
}

variable "policy_json" {
  description = "The policy document as JSON, typically from an aws_iam_policy_document data source or jsonencode()."
  type        = string

  validation {
    condition     = try(jsondecode(var.policy_json).Version == "2012-10-17" && length(jsondecode(var.policy_json).Statement) > 0, false)
    error_message = "policy_json must be a JSON policy with Version 2012-10-17 and a list of statements."
  }

  validation {
    condition = try(alltrue([
      for s in jsondecode(var.policy_json).Statement :
      !(try(s.Effect, "") == "Allow" && contains(flatten([try(s.Action, [])]), "*"))
    ]), false)
    error_message = "A statement allowing every action (\"*\") is refused: grant the actions the policy is for."
  }
}

variable "tags" {
  description = "Tags for the policy."
  type        = map(string)
  default     = {}
}
