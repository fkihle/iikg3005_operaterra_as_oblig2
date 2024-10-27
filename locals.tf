locals {
  common_tags = {
    company_name = var.company_name
    department   = var.department
    costcenter   = var.costcenter
    project_name = var.project_name
    environment  = terraform.workspace == "default" ? "" : terraform.workspace

  }
}