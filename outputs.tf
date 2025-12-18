
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = {
    Management  = azurerm_subnet.subnet_mgmt.id
    Web         = azurerm_subnet.subnet_web.id
    Application = azurerm_subnet.subnet_app.id
    Backend     = azurerm_subnet.subnet_backend.id
  }
}

output "nsg_ids" {
  value = {
    Management = azurerm_network_security_group.nsg_mgmt.id
    Web        = azurerm_network_security_group.nsg_web.id
  }
}

output "management_public_ip" {
  value       = azurerm_public_ip.mgmt_pip.ip_address
  description = "Public IP of the management VM"
}

output "storage_account_id" {
  value       = azurerm_storage_account.sa.id
  description = "Resource ID of the Storage Account"
}

output "storage_blob_endpoint" {
  value       = azurerm_storage_account.sa.primary_blob_endpoint
  description = "Blob endpoint (internal)"
}


output "storage_containers" {
  value       = [for c in azurerm_storage_container.containers : c.name]
  description = "Created containers"
}

