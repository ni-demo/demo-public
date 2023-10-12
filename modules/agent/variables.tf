variable "agent_count" {
  type = number
  validation {
    condition     = var.agent_count >= 0
    error_message = "Agent count must not be a negative number!"
  }
}

variable "ami_name_filter" {
  type = string
}

variable "azdo_org" {
  type = string
}

variable "azdo_pat" {
  type = string
}

variable "pool_name" {
  type = string
}

variable "project_id" {
  type = string
}