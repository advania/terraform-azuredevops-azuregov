variable "project_name" {
  type        = string
  default     = "Azure Governance"
  description = "Azure DevOps Project Name"
}

variable "project_description" {
  type        = string
  default     = "Advania Azure Governance Project"
  description = "Azure DevOps Project Description"
}

variable "pipeline_approval_team_name" {
  type        = string
  description = "Name of the pipeline approval team"
  default     = "Azure Governance Team"
}



variable "components" {
  type        = list(string)
  description = "List of components to deploy"
  default     = ["landing-zones", "monitoring", "networking", "policies", "azure-devops"]
}

variable "min_reviewers_enabled" {
  type        = bool
  description = "Enable min reviewers branch policy"
  default     = false
}

variable "min_reviewers_count" {
  type        = number
  description = "Min reviewers count"
  default     = 1
}

#Backend variables
variable "backend_storage_account_name" {
  type        = string
  description = "Name of the backend storage account"
  default     = ""
}

variable "backend_resource_group_name" {
  type        = string
  description = "Name of the backend resource group"
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID"
}

variable "subscription_name" {
  type        = string
  description = "Subscription Name"
}

variable "client_id" {
  type        = string
  description = "Client ID for backend service connection principal"
}

variable "subscription_vending_map" {
  type = map(object({
    enabled = bool
  }))
  description = "Subscription vending map"
  default     = {}
}



