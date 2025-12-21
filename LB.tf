# public IP + LB + probe + rule + BE pool assoc


############################################
# Public IP for the Load Balancer (Standard, Static)
############################################

resource "azurerm_public_ip" "lb_pip" {
  name                = var.lb_pip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "lb"
  }
}


############################################
# Standard Public Load Balancer
############################################

resource "azurerm_lb" "lb" {
  name                = var.lb_name
  resource_group_name = azurerm_resource_group.rg.name # ✅ keep here
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.lb_frontend_name
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "lb"
  }
}

############################################
# Backend pool for web NICs
############################################

resource "azurerm_lb_backend_address_pool" "lb_bepool" {
  name            = "web-backend"
  loadbalancer_id = azurerm_lb.lb.id # ✅ RG is implied by LB ID
}

############################################
# Health probe on TCP port 80
############################################

resource "azurerm_lb_probe" "lb_probe_http" {
  name            = "http-80"
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = "Tcp"
  port            = var.lb_http_backend_port
}

############################################
# Load balancing rule: HTTP 80 → 80
############################################

resource "azurerm_lb_rule" "lb_rule_http" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = var.lb_http_frontend_port
  backend_port                   = var.lb_http_backend_port
  frontend_ip_configuration_name = var.lb_frontend_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_bepool.id]
  probe_id                       = azurerm_lb_probe.lb_probe_http.id

}

