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

resource "azuredevops_branch_policy_auto_reviewers" "demo_owner_review_policy" {
  project_id = azuredevops_project.demo_project.id

  enabled  = true
  blocking = true

  settings {
    auto_reviewer_ids           = [local.admin_user.id]
    submitter_can_vote          = false
    minimum_number_of_reviewers = 1

    scope {
      repository_id  = azuredevops_git_repository.demo_repository.id
      repository_ref = azuredevops_git_repository.demo_repository.default_branch
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_min_reviewers" "demo_min_review_policy" {
  project_id = azuredevops_project.demo_project.id

  enabled  = true
  blocking = true

  settings {
    reviewer_count                         = 1
    submitter_can_vote                     = false
    last_pusher_cannot_approve             = true
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes           = true

    scope {
      repository_id  = azuredevops_git_repository.demo_repository.id
      repository_ref = azuredevops_git_repository.demo_repository.default_branch
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_group" "owner_group" {
  scope        = azuredevops_project.demo_project.id
  display_name = "Owners of demo-repository"
  members      = [local.admin_user.descriptor]
}

resource "azuredevops_git_permissions" "bypass_policy_permissions" {
  project_id    = azuredevops_project.demo_project.id
  repository_id = azuredevops_git_repository.demo_repository.id
  principal     = azuredevops_group.owner_group.id
  permissions = {
    PolicyExempt = "Allow"
  }
}

data "azuredevops_group" "contributors" {
  project_id = azuredevops_project.demo_project.id
  name       = "Contributors"
}

resource "azuredevops_git_permissions" "contributor_permissions" {
  project_id = azuredevops_project.demo_project.id
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
  members = [local.admin_user.descriptor, azuredevops_user_entitlement.demo_user.descriptor]
  lifecycle {
    ignore_changes = [group]
  }
}