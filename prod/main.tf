#Azure Secret for Service Principal
# Enable this variable if you have elected not to use a tfvars.tf file.
#variable "client_secret" {}

Provider Configuration
provider "azurerm" {
version = "=1.28.0"
  subscription_id = "${var.ARM_SUBSCRIPTION_ID}"
  client_id       = "${var.ARM_CLIENT_ID}"
  client_secret   = "${var.ARM_CLIENT_SECRET}"
  tenant_id       = "${var.ARM_TENANT_ID}"
}

#Backend Configuration for State
/*
terraform {
    backend "azurerm" {
    storage_account_name = "terraform"
    container_name       = "tfstate"
    key                  = "datascience/terraform.tfstate"

    # rather than defining this inline, the Access Key can also be sourced
    # from an Environment Variable - more information is available below.
    #access_key = "”
    access_key = ""
  }
}
*/

#ResourceGroup Management
resource "azurerm_resource_group" "dsvm" {
    name = "${var.resourcegroup}"
    location = "${var.location}"
}

resource "azurerm_virtual_network" "dsvm" {
  name                = "dsvm-vnet"
  address_space       = ["10.124.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.dsvm.name}"
}

resource "azurerm_subnet" "dsvm" {
  name                 = "dsvm-prod-subnet"
  resource_group_name  = "${azurerm_resource_group.dsvm.name}"
  virtual_network_name = "${azurerm_virtual_network.dsvm.name}"
  address_prefix       = "10.124.10.0/24"
}

resource "azurerm_network_interface" "dsvm" {
  name                = "dsvm_nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.dsvm.name}"

  ip_configuration {
    name                          = "dsvmipconfig"
    subnet_id                     = "${azurerm_subnet.dsvm.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "dsvm" {
  name                  = "${var.vm-name}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.dsvm.name}"
  network_interface_ids = ["${azurerm_network_interface.dsvm.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  plan {
    name = "linuxdsvm"
    publisher = "microsoft-ads"
    product = "linux-data-science-vm"
  }

  storage_image_reference {
    publisher = "microsoft-ads"
    offer     = "linux-data-science-vm"
    sku       = "linuxdsvm"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm-name}_osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "${var.vm-name}_data"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
    lun               = 0
    disk_size_gb      = "120"
  }

  os_profile {
    computer_name  = "${var.vm-name}"
    admin_username = "${var.adminuser}"
    admin_password = "${var.adminpassword}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    ApplicationName = "DataScience"
    CreatedBy = "Conrad Johnson"
  }

}
