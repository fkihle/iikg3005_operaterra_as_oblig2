locals {
  common_tags = {
    company_name = var.company_name
    department   = var.department
    costcenter   = "${var.department}${var.project_id}"
    project_name = var.project_name
    environment  = terraform.workspace == "default" ? "" : terraform.workspace
  }

  workspace_suffix = terraform.workspace == "default" ? "" : "${terraform.workspace}"
  project_name     = "${var.project_name}${local.workspace_suffix}"
}