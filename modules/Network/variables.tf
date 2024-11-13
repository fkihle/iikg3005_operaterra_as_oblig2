variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string

}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)

}

variable "vnet_range" {
  description = "The range of the virtual network"
  type        = string
}

variable "subnet_ranges" {
  description = "The ranges of the subnets"
  type        = list(string)
}

variable "source_content" {
  description = "Source content for the index.html file"
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group"
  type        = string

}