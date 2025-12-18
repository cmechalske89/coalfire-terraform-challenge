

# Management subnet (with service endpoint to Storage for later SA firewall rules)
resource "azurerm_subnet" "subnet_mgmt" {
  name                 = "Management"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_mgmt]
  service_endpoints    = ["Microsoft.Storage"]
}

# Web subnet
resource "azurerm_subnet" "subnet_web" {
  name                 = "Web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_web]
}

# Application subnet (KV + Storage endpoints as needed)
resource "azurerm_subnet" "subnet_app" {
  name                 = "Application"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_app]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

# Backend subnet
resource "azurerm_subnet" "subnet_backend" {
  name                 = "Backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_backend]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]

}

