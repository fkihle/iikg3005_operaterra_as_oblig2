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

variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}

variable "source_content" {
  description = "The content of the website"
  type        = string
}

variable "index_document" {
  description = "The index document of the website"
  type        = string
}