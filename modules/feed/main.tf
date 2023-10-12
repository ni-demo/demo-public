resource "null_resource" "feed" {
  depends_on = [var.project_name]
  triggers = {
    azdo_org     = var.azdo_org
    azdo_pat     = var.azdo_pat
    project_name = var.project_name
    feed_name    = var.feed_name
  }

  provisioner "local-exec" {
    command = "cd '${path.module}/scripts' && bash create.sh"
    environment = {
      azdo_org     = self.triggers.azdo_org
      azdo_pat     = self.triggers.azdo_pat
      project_name = self.triggers.project_name
      feed_name    = self.triggers.feed_name
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "cd '${path.module}/scripts' && bash destroy.sh"
    environment = {
      azdo_org     = self.triggers.azdo_org
      azdo_pat     = self.triggers.azdo_pat
      project_name = self.triggers.project_name
      feed_name    = self.triggers.feed_name
    }
  }
}