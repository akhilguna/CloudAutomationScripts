provider "azurerm" {
  features {}
}

variable "admin_username" {
  description = "netrich"
}

variable "admin_password" {
  description = "netrich@1234"
}

# Define the two locations
variable "locations" {
  default = ["East US", "West US"]
}

# Create resource groups in each location
resource "azurerm_resource_group" "rg" {
  count    = length(var.locations)
  name     = "rg-${replace(var.locations[count.index], " ", "-")}"
  location = var.locations[count.index]
}

# Create a virtual network and subnet in each resource group
resource "azurerm_virtual_network" "vnet" {
  count               = length(var.locations)
  name                = "vnet-${replace(var.locations[count.index], " ", "-")}"
  address_space       = ["10.0.${count.index}.0/24"]
  location            = azurerm_resource_group.rg[count.index].location
  resource_group_name = azurerm_resource_group.rg[count.index].name
}

resource "azurerm_subnet" "subnet" {
  count                = length(var.locations)
  name                 = "subnet-${replace(var.locations[count.index], " ", "-")}"
  resource_group_name  = azurerm_resource_group.rg[count.index].name
  virtual_network_name = azurerm_virtual_network.vnet[count.index].name
  address_prefixes     = ["10.0.${count.index}.0/25"]
}


# Create two VMs in each location
resource "azurerm_linux_virtual_machine" "vm" {
  count               = 4
  name                = "vm-${count.index + 1}"
  location            = azurerm_resource_group.rg[count.index % 2].location
  resource_group_name = azurerm_resource_group.rg[count.index % 2].name
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false

  source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
  version   = "latest"
  }
  /*source_image_reference {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter"
  version   = "latest"
 }*/


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

# Create a network interface for each VM
resource "azurerm_network_interface" "nic" {
  count               = 4
  name                = "nic-${count.index + 1}"
  location            = azurerm_resource_group.rg[count.index % 2].location
  resource_group_name = azurerm_resource_group.rg[count.index % 2].name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet[count.index % 2].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "example" {
  name                = "example-publicip"
  location            = azurerm_resource_group.rg[count.index % 2].location
  resource_group_name = azurerm_resource_group.rg[count.index % 2].name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.rg[count.index % 2].location
  resource_group_name = azurerm_resource_group.rg[count.index % 2].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}
