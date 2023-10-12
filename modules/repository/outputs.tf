output "repository_id" {
  value = azuredevops_git_repository.repository.id
}

output "default_branch" {
  value = azuredevops_git_repository.repository.default_branch
}