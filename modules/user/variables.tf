variable "email_address" {
  type = string
}

variable "type" {
  type = string
  validation {
    condition     = var.type == "resource" || var.type == "data"
    error_message = "Type must be either 'resource' or 'data'!"
  }
}