locals {
  contributor_ids         = var.contributors[*].id
  contributor_descriptors = var.contributors[*].descriptor
}

resource "azuredevops_project" "project" {
  name        = var.name
  description = var.description

  features = {
    "boards"       = "disabled"
    "repositories" = "enabled"
    "pipelines"    = "enabled"
    "testplans"    = "disabled"
    "artifacts"    = "disabled"
  }
}

data "azuredevops_group" "contributors" {
  project_id = azuredevops_project.project.id
  name       = "Contributors"
}

resource "azuredevops_git_permissions" "contributor_permissions" {
  project_id = azuredevops_project.project.id
  principal  = data.azuredevops_group.contributors.id
  permissions = {
    ForcePush = "Allow"
  }
  lifecycle {
    ignore_changes = [principal]
  }
}

resource "azuredevops_group_membership" "contributor_memberships" {
  group   = data.azuredevops_group.contributors.descriptor
  members = local.contributor_descriptors
  lifecycle {
    ignore_changes = [group]
  }
}