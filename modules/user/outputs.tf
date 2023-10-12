locals {
  data_user_list = var.type == "data" ? data.azuredevops_users.user_list[0] : null
  data_user      = var.type == "data" ? tolist(local.data_user_list.users)[0] : null
  resource_user  = var.type == "resource" ? azuredevops_user_entitlement.user[0] : null
}

output "id" {
  value = var.type == "data" ? local.data_user.id : local.resource_user.id
}

output "descriptor" {
  value = var.type == "data" ? local.data_user.descriptor : local.resource_user.descriptor
}