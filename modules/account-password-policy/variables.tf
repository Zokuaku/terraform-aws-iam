variable "minimum_password_length" {
  description = "Minimum length of an IAM user password. The baseline is 14; the module refuses anything shorter."
  type        = number
  default     = 14

  validation {
    condition     = var.minimum_password_length >= 14 && var.minimum_password_length <= 128
    error_message = "minimum_password_length must be between 14 (the baseline) and 128."
  }
}

variable "password_reuse_prevention" {
  description = "How many previous passwords a user may not reuse."
  type        = number
  default     = 24

  validation {
    condition     = var.password_reuse_prevention >= 1 && var.password_reuse_prevention <= 24
    error_message = "password_reuse_prevention must be between 1 and 24."
  }
}

variable "max_password_age" {
  description = "Days a password stays valid. 0 means passwords never expire, which the module refuses."
  type        = number
  default     = 90

  validation {
    condition     = var.max_password_age >= 1 && var.max_password_age <= 1095
    error_message = "max_password_age must be between 1 and 1095 days; passwords that never expire are not allowed."
  }
}

variable "require_symbols" {
  description = "Require at least one non-alphanumeric character."
  type        = bool
  default     = true
}

variable "require_numbers" {
  description = "Require at least one number."
  type        = bool
  default     = true
}

variable "require_uppercase_characters" {
  description = "Require at least one upper-case letter."
  type        = bool
  default     = true
}

variable "require_lowercase_characters" {
  description = "Require at least one lower-case letter."
  type        = bool
  default     = true
}

variable "allow_users_to_change_password" {
  description = "Let users change their own password."
  type        = bool
  default     = true
}

variable "hard_expiry" {
  description = "When true, a user whose password has expired cannot set a new one and needs an administrator."
  type        = bool
  default     = false
}
