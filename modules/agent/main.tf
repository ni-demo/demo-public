data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}

resource "azuredevops_agent_pool" "agent_pool" {
  name           = var.pool_name
  auto_provision = false
  auto_update    = false
}

resource "azuredevops_agent_queue" "agent_queue" {
  project_id    = var.project_id
  agent_pool_id = azuredevops_agent_pool.agent_pool.id

  lifecycle {
    replace_triggered_by = [azuredevops_agent_pool.agent_pool.name]
  }
}

resource "azuredevops_pipeline_authorization" "agent_queue_authorization" {
  project_id  = var.project_id
  resource_id = azuredevops_agent_queue.agent_queue.id
  type        = "queue"

  lifecycle {
    ignore_changes = [pipeline_id]
  }
}

resource "aws_instance" "agent" {
  count                       = var.agent_count
  depends_on                  = [azuredevops_agent_pool.agent_pool]
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  user_data = templatefile("${path.root}/.agent/agent.sh", {
    azdo_org  = var.azdo_org
    azdo_pat  = var.azdo_pat,
    azdo_pool = var.pool_name
  })
  user_data_replace_on_change = true

  tags = {
    Name = "${var.pool_name}-agent"
  }
}