# Accepting Azure Market Place Acknowledgement

To deploy an Azure Data Science Machine you must accept the Market Place Argeement prior.

# Terraform.tfvars File Creation

Be sure to add a tfvars file in the dev / production folder.  The creation of a production Terraform will utilize a high dollar GPU processor.  I do not recommend this unless you wish to be charged.  Feel free to modify and consume anyway you wish.  I am not responsible for any cost inquired by the use of this terraform deployment to your Azure Subcription.

```powershell
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