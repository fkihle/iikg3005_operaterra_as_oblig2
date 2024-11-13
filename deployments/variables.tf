# DEPENDENCY variables
variable "subscription_id" {
  type        = string
  description = "The subscription GUID for connection to Azure tennant"
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
  default     = "10.0.0.0/24"
}

variable "subnet_ranges" {
  type        = list(string)
  description = "The ranges of the subnets"
  default = [
    "10.0.0.0/25",
    "10.0.0.128/25",
  ]
}

# WEB
variable "index_document" {
  type        = string
  description = "Name of the index document"
  default     = "index.html"
}

# COMMON TAGS
variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = "fk2"
}

variable "company_name" {
  type        = string
  description = "The name of the company"
  default     = "Opera Terra AS"

}

variable "department" {
  type        = string
  description = "The department"
  default     = "it"
}

variable "project_id" {
  type        = string
  description = "The project ID"
  default     = "00042"
}