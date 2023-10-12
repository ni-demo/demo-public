moved {
  from = azuredevops_git_repository.demo_repository
  to   = module.demo_repository.azuredevops_git_repository.repository
}

moved {
  from = azuredevops_branch_policy_auto_reviewers.demo_owner_review_policy
  to   = module.demo_repository.azuredevops_branch_policy_auto_reviewers.owner_review_policy
}

moved {
  from = azuredevops_branch_policy_min_reviewers.demo_min_review_policy
  to   = module.demo_repository.azuredevops_branch_policy_min_reviewers.min_review_policy
}

moved {
  from = azuredevops_git_permissions.bypass_policy_permissions
  to   = module.demo_repository.azuredevops_git_permissions.bypass_policy_permissions
}

moved {
  from = azuredevops_group.owner_group
  to   = module.demo_repository.azuredevops_group.owner_group
}

moved {
  from = azuredevops_project.demo_project
  to   = module.demo_project.azuredevops_project.project
}

moved {
  from = azuredevops_git_permissions.contributor_permissions
  to   = module.demo_project.azuredevops_git_permissions.contributor_permissions
}

moved {
  from = azuredevops_group_membership.contributor_memberships
  to   = module.demo_project.azuredevops_group_membership.contributor_memberships
}

moved {
  from = azuredevops_user_entitlement.demo_user
  to   = module.demo_user.azuredevops_user_entitlement.user[0]
}