resource "azuredevops_project" "demo_project" {
  name        = "Demo"
  description = "This project is managed by Terraform."

  features = {
    "boards"       = "disabled"
    "repositories" = "enabled"
    "pipelines"    = "disabled"
    "testplans"    = "disabled"
    "artifacts"    = "disabled"
  }
}

resource "azuredevops_git_repository" "demo_repository" {
  project_id     = azuredevops_project.demo_project.id
  name           = "demo-repository"
  default_branch = "refs/heads/main"

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_user_entitlement" "demo_user" {
  principal_name = var.demo_user_email
}

data "azuredevops_users" "admin_user_list" {
  principal_name = "ni.demo.szakmai.napok@gmail.com"
}

locals {
  admin_user = tolist(data.azuredevops_users.admin_user_list.users)[0]
}