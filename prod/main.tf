#Azure Secret for Service Principal
# Enable this variable if you have elected not to use a tfvars.tf file.
#variable "client_secret" {}

# Azure Provider Configuration
provider "azurerm" {
  version         = "=1.28.0"
  subscription_id = "${var.ARM_SUBSCRIPTION_ID}"
  client_id       = "${var.ARM_CLIENT_ID}"
  client_secret   = "${var.ARM_CLIENT_SECRET}"
  tenant_id       = "${var.ARM_TENANT_ID}"
}

# Azure Blob Backend Configuration for State
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

# Azure Resource Group Creation
resource "azurerm_resource_group" "dsvm-rsg" {
  name     = "${var.resourcegroup}"
  location = "${var.location}"
}

# Azure Vnet Creation
resource "azurerm_virtual_network" "dsvm-vnet" {
  name                = "dsvm-vnet"
  address_space       = ["10.124.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.dsvm-rsg.name}"
}

# Azure Subnet Creation
resource "azurerm_subnet" "dsvm-subnet" {
  name                 = "dsvm-prod-subnet"
  resource_group_name  = "${azurerm_resource_group.dsvm-rsg.name}"
  virtual_network_name = "${azurerm_virtual_network.dsvm-vnet.name}"
  address_prefix       = "10.124.10.0/24"
}

#Azure Security Group Creation
resource "azurerm_network_security_group" "dsvm-nsg" {
  name                = "datascience-sg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.dsvm-rsg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.124.10.2"
    destination_address_prefix = "*"
  }
}

# Azure Networker Interface Creation
resource "azurerm_network_interface" "dsvm-nic" {
  name                      = "dsvm_nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.dsvm-rsg.name}"
  network_security_group_id = "${azurerm_network_security_group.dsvm-nsg.id}"

  ip_configuration {
    name                          = "dsvmipconfig"
    subnet_id                     = "${azurerm_subnet.dsvm-subnet.id}"
    private_ip_address_allocation = "dynamic"
  }
}

# Azure Storage Service Crreation
// resource "azurerm_storage_account" "dsvmstor" {
//   name                     = "dsvmstor"
//   resource_group_name      = "${azurerm_resource_group.dsvm-rsg.name}"
//   location                 = "${var.location}"
//   account_tier             = "Standard"
//   account_replication_type = "LRS"

//   tags = {
//     application = "DSVM Storage"
//   }
// }

# Azure Virtual Machine Instance Creation
resource "azurerm_virtual_machine" "dsvm-instance" {
  name                             = "${var.vm-name}"
  location                         = "${var.location}"
  resource_group_name              = "${azurerm_resource_group.dsvm-rsg.name}"
  network_interface_ids            = ["${azurerm_network_interface.dsvm-nic.id}"]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = false

  plan {
    name      = "linuxdsvm"
    publisher = "microsoft-ads"
    product   = "linux-data-science-vm"
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
    disk_size_gb      = "1"
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
    CreatedBy       = "Conrad Johnson"
  }
}
