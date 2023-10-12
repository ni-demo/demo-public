terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.9.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/${var.azdo_org}"
  personal_access_token = var.azdo_pat
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}