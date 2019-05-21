# Terraform Azure CentOS DataScience

## Accepting Azure Market Place Acknowledgement

To deploy an Azure Data Science Machine you must accept the Market Place Argeement prior. Please follow the see the web reference below on how to accept Market Place images.

https://blogs.technet.microsoft.com/stefan_stranger/2018/03/25/lessons-learned-deploying-azure-marketplace-virtual-machine/

## Terraform.tfvars File Creation

Be sure to add a terraform.tfvars file in the dev / prod folder.  The creation of a production Terraform will utilize a high dollar GPU processor.  I do not recommend this unless you wish to be charged at high dollar.

```powershell
# Azure Subscription Configuration
variable "ARM_SUBSCRIPTION_ID" {
default = "<Azure Subscription ID>"
}
variable "ARM_CLIENT_ID" {
default = "<Service Principle Client ID>"
}
variable "ARM_CLIENT_SECRET" {
default = "<Service Principle Secret>"
}
variable "ARM_TENANT_ID" {
default = "<Azure Tenant Id>"
}

#DSVM Variables
variable "vm-name" {
  default = "<DSVM Machine Name>"
}
variable "location" {
  default = "<Azure Region>"
}
variable "resourcegroup" {
  default = "<Resource Group Name>"
}

variable "adminuser" {
  default = "<Local Admin User to DSVM>"
}

variable "adminpassword" {
  default = "<password>"
}
```