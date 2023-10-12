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
  }
}