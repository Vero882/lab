output "public_ip" {
  value = azurerm_public_ip.terraform-pip01.ip_address
}