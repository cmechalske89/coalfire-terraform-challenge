# web NICs + VMs


############################################
# NICs for Web VMs (no public IPs)
############################################

resource "azurerm_network_interface" "nic_web" {
  count               = var.web_vm_count
  name                = "${var.resource_group_name}-nic-web-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet_web.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "web"
  }
}

############################################
# Associate Web NICs to the Load Balancer backend pool
############################################

resource "azurerm_network_interface_backend_address_pool_association" "web_nic_lb" {
  count                   = var.web_vm_count
  network_interface_id    = azurerm_network_interface.nic_web[count.index].id
  ip_configuration_name   = azurerm_network_interface.nic_web[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_bepool.id
}

############################################
# Two Ubuntu 22.04 web VMs in the Availability Set
# - No public IP addresses
# - Apache installed via cloud-init YAML
############################################


resource "azurerm_linux_virtual_machine" "vm_web" {
  count               = var.web_vm_count

  # Sanitize RG name: lowercase and replace underscores with hyphens
  name                = "${replace(lower(var.resource_group_name), "_", "-")}-vm-web-${count.index}"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.web_vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic_web[count.index].id]


  # Place VMs in your Availability Set
  availability_set_id = azurerm_availability_set.web_as.id

  # We are enforcing SSH key-only auth (no passwords)
  disable_password_authentication = true


  dynamic "admin_ssh_key" {
    for_each = var.ssh_public_key == null ? [] : [var.ssh_public_key]
    content {
      username   = var.admin_username
      public_key = file(pathexpand(admin_ssh_key.value)) # ✅ expands "~" to your home directory
    }
  }


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

  # Cloud-init to install Apache and write a simple index.html
  # Terraform docs support cloud-init via base64-encoded custom_data
  #   (we use filebase64 to read your YAML file)
  custom_data = filebase64(local.cloud_init_web_path)

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "web"
  }
}
