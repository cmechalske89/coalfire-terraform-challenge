

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = [var.vnet_cidr]

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "network"
  }
}




