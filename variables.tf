variable "azdo_pat" {
  type        = string
  sensitive   = true
  description = "Personal access token used to connect to Azure DevOps"
}

variable "azdo_org" {
  type        = string
  sensitive   = false
  description = "Name of the Azure DevOps organization"
}

variable "aws_region" {
  type        = string
  sensitive   = false
  description = "Region used by the AWS account"
}

variable "aws_access_key" {
  type        = string
  sensitive   = false
  description = "Access key of the AWS account"
}

variable "aws_secret_key" {
  type        = string
  sensitive   = true
  description = "Secret key of the AWS account"
}

variable "demo_user_email" {
  type        = string
  sensitive   = false
  description = "Email adress of the user to be created"
}