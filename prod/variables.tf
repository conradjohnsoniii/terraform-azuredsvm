# Required Variables in .tfvars 
variable "ARM_SUBSCRIPTION_ID" {
  description = "Azure Subcription ID"
}

variable "ARM_CLIENT_ID" {
  description = "Azure Client ID"
}

variable "ARM_CLIENT_SECRET" {
  description = "Azure Client Secret"
}

variable "ARM_TENANT_ID" {
  description = "Azure Tenant ID"
}

#DSVM Variables
variable "vm-name" {
  description = "Azure Virtual Instance Name"
  default     = "dsvm-prod"
}

variable "location" {
  description = "Azure Region of Deployment"
  default     = "eastus"
}

variable "resourcegroup" {
  description = "Azure Resource Group Name"
  default     = "prod-dsvm"
}

variable "adminuser" {
  description = "Azure Local Admin User"
  default     = "azureuser"
}

variable "adminpassword" {
  description = "Azure Local Admin password"
}
