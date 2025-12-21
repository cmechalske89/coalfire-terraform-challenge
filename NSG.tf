

############################################
# NSGs for Management and Web subnets
############################################

# Management NSG: allow SSH from a single trusted CIDR; deny all other inbound
resource "azurerm_network_security_group" "nsg_mgmt" {
  name                = "${var.resource_group_name}-nsg-mgmt"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "mgmt"
  }

  # Allow SSH from your admin CIDR
  security_rule {
    name                       = "Allow-SSH-From-Trusted"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = var.admin_allowed_cidr
    destination_address_prefix = "*"
  }

  # Deny all other inbound
  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Web NSG: allow HTTP from Azure Load Balancer service tag; allow SSH only from Mgmt subnet; deny all else
resource "azurerm_network_security_group" "nsg_web" {
  name                = "${var.resource_group_name}-nsg-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "web"
  }

  # Allow HTTP (80) from Azure Load Balancer (covers health probes and client traffic via LB)
  security_rule {
    name                       = "Allow-HTTP-From-AzureLoadBalancer"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # Allow SSH (22) only from the Management subnet CIDR
  security_rule {
    name                       = "Allow-SSH-From-Mgmt"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = var.subnet_mgmt
    destination_address_prefix = "*"
  }

  # Deny all other inbound
  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

############################################
# Associate NSGs to subnets
############################################

resource "azurerm_subnet_network_security_group_association" "assoc_mgmt" {
  subnet_id                 = azurerm_subnet.subnet_mgmt.id
  network_security_group_id = azurerm_network_security_group.nsg_mgmt.id
}

resource "azurerm_subnet_network_security_group_association" "assoc_web" {
  subnet_id                 = azurerm_subnet.subnet_web.id
  network_security_group_id = azurerm_network_security_group.nsg_web.id
}