resource "azurerm_resource_group" "terraform-rg01" {
  name     = "terraform-rg01"
  location = var.region
}

resource "azurerm_virtual_network" "terraform-vnet01" {
  name                = "terraform-vnet01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terraform-rg01.location
  resource_group_name = azurerm_resource_group.terraform-rg01.name
}

resource "azurerm_subnet" "terraform-subnet01" {
  name                 = "terraform-subnet01"
  resource_group_name  = azurerm_resource_group.terraform-rg01.name
  virtual_network_name = azurerm_virtual_network.terraform-vnet01.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "terraform-nsg01" {
  name                = "terraform-nsg01"
  location            = azurerm_resource_group.terraform-rg01.location
  resource_group_name = azurerm_resource_group.terraform-rg01.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "terraform-nic01" {
  name                = "terraform-nic01"
  location            = azurerm_resource_group.terraform-rg01.location
  resource_group_name = azurerm_resource_group.terraform-rg01.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terraform-subnet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraform-pip01.id
  }
}

resource "azurerm_network_interface_security_group_association" "terraform-nic01-nsg01" {
  network_interface_id      = azurerm_network_interface.terraform-nic01.id
  network_security_group_id = azurerm_network_security_group.terraform-nsg01.id
}

resource "azurerm_public_ip" "terraform-pip01" {
  name                = "terraform-pip01"
  location            = azurerm_resource_group.terraform-rg01.location
  resource_group_name = azurerm_resource_group.terraform-rg01.name
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "terraform-vm01" {
  name                = "terraform-vm01"
  resource_group_name = azurerm_resource_group.terraform-rg01.name
  location            = azurerm_resource_group.terraform-rg01.location
  size                = var.vm-size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.terraform-nic01.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

}

