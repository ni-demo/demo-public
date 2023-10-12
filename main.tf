module "admin_user" {
  source = "./modules/user"

  email_address = "ni.demo.szakmai.napok@gmail.com"
  type          = "data"
}

module "demo_user" {
  source = "./modules/user"

  email_address = var.demo_user_email
  type          = "resource"
}

module "demo_project" {
  source = "./modules/project"

  name         = "Demo"
  description  = "This project is managed by Terraform."
  contributors = [module.admin_user, module.demo_user]
}

module "demo_repository" {
  source = "./modules/repository"

  owners          = [module.admin_user]
  project_id      = module.demo_project.id
  repository_name = "demo-repository"
}