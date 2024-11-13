# DEPENDENCY variables
variable "subscription_id" {
  type        = string
  description = "The subscription GUID for connection to Azure tennant"
  default     = "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription"
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
  default = "10.0.0.0/24"
}

variable "subnet_ranges" {
  type        = list(string)
  description = "The ranges of the subnets"
  default = [ 
    "10.0.0.0/25",
    "10.0.0.128/25", ]
}

# WEB
variable "source_content" {
  type        = string
  description = "Source content for the index.html file"
  default     = "<h1>Default content - CI/CD</h1>"
}

variable "index_document" {
  type        = string
  description = "Name of the index document"
  default     = "index.html"
}





