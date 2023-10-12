data "azuredevops_users" "user_list" {
  count          = var.type == "data" ? 1 : 0
  principal_name = var.email_address
}

resource "azuredevops_user_entitlement" "user" {
  count          = var.type == "resource" ? 1 : 0
  principal_name = var.email_address
}