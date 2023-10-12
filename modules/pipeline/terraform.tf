terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.9.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}