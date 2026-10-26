variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
  description = "Map of resource groups to provision using for_each key-value pairs"
}

variable "default_tags" {
  type        = map(string)
  default     = {}
  description = "Baseline enterprise governance tags merged with every resource group"
}
