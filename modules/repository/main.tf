locals {
  owner_ids         = var.owners[*].id
  owner_descriptors = var.owners[*].descriptor
}

resource "azuredevops_git_repository" "repository" {
  project_id     = var.project_id
  name           = var.repository_name
  default_branch = "refs/heads/main"

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_branch_policy_auto_reviewers" "owner_review_policy" {
  depends_on = [azuredevops_git_permissions.bypass_policy_permissions]
  project_id = var.project_id

  enabled  = true
  blocking = true

  settings {
    auto_reviewer_ids           = local.owner_ids
    submitter_can_vote          = false
    minimum_number_of_reviewers = 1

    scope {
      repository_id  = azuredevops_git_repository.repository.id
      repository_ref = azuredevops_git_repository.repository.default_branch
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_min_reviewers" "min_review_policy" {
  depends_on = [azuredevops_git_permissions.bypass_policy_permissions]
  project_id = var.project_id

  enabled  = true
  blocking = true

  settings {
    reviewer_count                         = 1
    submitter_can_vote                     = false
    last_pusher_cannot_approve             = true
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes           = true

    scope {
      repository_id  = azuredevops_git_repository.repository.id
      repository_ref = azuredevops_git_repository.repository.default_branch
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_group" "owner_group" {
  scope        = var.project_id
  display_name = "Owners of ${var.repository_name}"
  members      = local.owner_descriptors
}

resource "azuredevops_git_permissions" "bypass_policy_permissions" {
  project_id    = var.project_id
  repository_id = azuredevops_git_repository.repository.id
  principal     = azuredevops_group.owner_group.id
  permissions = {
    PolicyExempt = "Allow"
  }
}