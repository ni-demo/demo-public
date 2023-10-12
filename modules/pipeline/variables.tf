variable "branch" {
  type = string
}

variable "commit_message" {
  type = string
}

variable "pipeline_name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "repository_id" {
  type = string
}

variable "template_variables" {
  type = map(string)
}

variable "yml_path" {
  type = string
}