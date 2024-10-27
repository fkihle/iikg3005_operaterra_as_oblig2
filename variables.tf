# DEPENDENCY variables
variable "subscription_id" {
  type        = string
  description = "The subscription GUID for connection to Azure tennant"
  default     = "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription"
}

# COMMON TAG variables
variable "company_name" {
  type        = string
  description = "Company name"
}

# Departmant of the organisation 
variable "department" {
  type        = string
  description = "Department that the resource belongs to."

  validation {
    condition     = contains(["it", "rnd", "finance", "hr"], var.department)
    error_message = "Incorrect department given. Please choose from: it, rnd, finance, hr."
  }
}

variable "costcenter" {
  type        = string
  description = "Department name used for accounting (inherited from ResourceGroup module)"
  default     = "IT"
}

variable "project_name" {
  type        = string
  description = "Project name used for all resources (inherited from ResourceGroup module)"
  default     = "Unnamed project"
}

# RESOURCE GROUP variables
variable "location" {
  type        = string
  description = "Area for hosting the project resources"
  default     = "westeurope"
}

# Resource groupe name
variable "rg_name" {
  type        = string
  description = "Name of the resource group"
  default     = "web"
}

# Storage Account Name
variable "sa_name" {
  type        = string
  description = "Storage account name"
  default     = "sa"
}

# NETWORK variables
variable "vnet_range" {
  type        = string
  description = "Desired virtual network range"
  default     = "10.0.0.0/24"
}

variable "subnet_ranges" {
  type        = list(string)
  description = "List of desired subnet ranges"
  default     = ["10.0.0.0/25", "10.0.0.128/25"]
}

# DATABASE variables
variable "db_name" {
  type        = string
  description = "Name of the database"
  default     = "unnamed"
  
}

# WEB APP variables
variable "index_document" {
  type        = string
  description = "Name of the index html document"
  default     = "index.html"
}

variable "source_content" {
  type        = string
  description = "Content of the website"
  default     = "<h1>Terraform - CI/CD</h1>"

}

# variable "subnet_ids" {    # TODO: Associate Key Vault to subnets
#   type        = list(string)
#   description = "List of subnet IDs"
# }

# VIRTUAL MACHINE variables
# variable "vm_names" {
#   type        = list(string)
#   description = "Virtual Machine names"
#   default     = ["VM-01"]
# }