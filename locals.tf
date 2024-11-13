locals {
  common_tags = {
    company_name = "Opera Terra AS"
    department   = "it"
    project_name = "fk2"
    project_id   = "00042"
    costcenter   = "${var.department}${var.project_id}"
    environment  = terraform.workspace == "default" ? "" : terraform.workspace
  }

  workspace_suffix = terraform.workspace == "default" ? "" : "${terraform.workspace}"
  project_name     = "${var.project_name}${local.workspace_suffix}"

  # Web
  source_content = "<h1>HEll0 W0rld!</h1>"
}