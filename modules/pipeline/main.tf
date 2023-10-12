resource "null_resource" "replace_trigger" {
  triggers = {
    template_variable_keys   = join(", ", keys(var.template_variables))
    template_variable_values = join(", ", values(var.template_variables))
  }
}

resource "azuredevops_git_repository_file" "pipeline_yml" {
  repository_id       = var.repository_id
  file                = var.yml_path
  content             = templatefile("${path.root}/${var.yml_path}", var.template_variables)
  branch              = var.branch
  commit_message      = var.commit_message
  overwrite_on_create = true

  lifecycle {
    ignore_changes       = [content, commit_message]
    replace_triggered_by = [null_resource.replace_trigger]
  }
}

resource "azuredevops_build_definition" "pipeline" {
  project_id = var.project_id
  name       = var.pipeline_name

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = var.repository_id
    branch_name = var.branch
    yml_path    = var.yml_path
  }
}