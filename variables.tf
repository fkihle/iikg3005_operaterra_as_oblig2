# DEPENDENCY variables
variable "subscription_id" {
  type        = string
  description = "The subscription GUID for connection to Azure tennant"
  default     = "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription"
}

# COMMON TAGS
variable "company_name" {
  type        = string
  description = "The name of the company"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "project_id" {
  type        = string
  description = "The project ID"
}

variable "department" {
  type        = string
  description = "The department"
  default     = "it"
}

# RESOURCE GROUP
variable "location" {
  type        = string
  description = "Location of the resource group"
  default     = "westeurope"
}

# NETWORK
variable "vnet_range" {
  type        = string
  description = "The range of the virtual network"
}

variable "subnet_ranges" {
  type        = list(string)
  description = "The ranges of the subnets"
}

# WEB
variable "source_content" {
  type        = string
  description = "Source content for the index.html file"
  default     = "<h1>Made with Terraform - CI/CD - update del 2</h1>"
}

variable "index_document" {
  type        = string
  description = "Name of the index document"
  default     = "index.html"
}





