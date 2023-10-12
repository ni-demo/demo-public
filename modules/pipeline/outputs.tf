output "pipeline_id" {
  value = azuredevops_build_definition.pipeline.id
}

output "yml_file_id" {
  value = azuredevops_git_repository_file.pipeline_yml.id
}