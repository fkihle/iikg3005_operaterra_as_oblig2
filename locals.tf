locals {
  common_tags = {
    company_name = var.company_name
    department   = var.department
    project_name = var.project_name
    project_id   = var.project_id
    costcenter   = "${var.department}-${var.project_id}"
    environment  = terraform.workspace == "default" ? "" : terraform.workspace
  }

  workspace_suffix = terraform.workspace == "default" ? "" : "${terraform.workspace}"
  project_name     = "${var.project_name}${local.workspace_suffix}"

  # Web
  source_content = "<h1>HEll0 W0rld!</h1>"
}