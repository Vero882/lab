resource "azurerm_resource_group" "terraform-rg01" {
  name     = "terraform-rg01"
  location = var.region
}

resource "azurerm_virtual_network" "terraform-vnet01" {
  name                = "terraform-vnet01"
  address_space       = ["10.0.0.0/16"]
  location           = azurerm_resource_group.terraform-rg01.location
  resource_group_name = azurerm_resource_group.terraform-rg01.name
}

resource "azurerm_subnet" "terraform-subnet01" {
  name                 = "terraform-subnet01"
  resource_group_name  = azurerm_resource_group.terraform-rg01.name
  virtual_network_name = azurerm_virtual_network.terraform-vnet01.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_insterface" "terraform-nic01" {
  name                = "terraform-nic01"
  location            = azurerm_resource_group.terraform-rg01.location
  resource_group_name = azurerm_resource_group.terraform-rg01.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terraform-subnet01.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "terraform-vm01" {
  name                = "terraform-vm01"
  resource_group_name = azurerm_resource_group.terraform-rg01.name
  location            = azurerm_resource_group.terraform-rg01.location
  size                = var.vm-size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_insterface.terraform-nic01.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/github.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "24.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "terraform-pip01" {
  name                = "terraform-pip01"
  location            = azurerm_resource_group.terraform-rg01.location
  resource_group_name = azurerm_resource_group.terraform-rg01.name
  allocation_method   = "Static"
}
