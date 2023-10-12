variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "contributors" {
  type = list(object({
    id         = string,
    descriptor = string
  }))
  default = []
}