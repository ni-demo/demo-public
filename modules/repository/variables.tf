variable "owners" {
  type = list(object({
    id         = string,
    descriptor = string
  }))
}

variable "project_id" {
  type = string
}

variable "repository_name" {
  type = string
}