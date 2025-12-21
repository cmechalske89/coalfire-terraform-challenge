
############################################
# Management VM (Ubuntu 22.04 LTS)
############################################

# Public IP for the management VM
resource "azurerm_public_ip" "mgmt_pip" {
  name                = "${var.resource_group_name}-mgmt-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "mgmt"
  }
}

# NIC for the management VM (in Management subnet)
resource "azurerm_network_interface" "nic_mgmt" {
  name                = "${var.resource_group_name}-nic-mgmt"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet_mgmt.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgmt_pip.id
  }

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "mgmt"
  }
}

# Ubuntu 22.04 LTS management VM
resource "azurerm_linux_virtual_machine" "vm_mgmt" {
  name                  = "${var.resource_group_name}-vm-mgmt"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = var.mgmt_vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic_mgmt.id]

  # If ssh_public_key is provided, use key auth

  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_key == null ? [] : [var.ssh_public_key]
    content {
      username   = var.admin_username
      public_key = file(pathexpand(admin_ssh_key.value)) # ✅ expands "~" to your home directory
    }
  }



  disable_password_authentication = true

  # Optional: allow password auth if you prefer (NOT recommended).
  # Uncomment if you set var.admin_password.
  # admin_password                  = var.admin_password
  # disable_password_authentication = var.admin_password == null

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "mgmt"
  }
}




