terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.9.1"
    }
  }
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/${var.azdo_org}"
  personal_access_token = var.azdo_pat
}