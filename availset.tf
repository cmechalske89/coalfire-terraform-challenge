
# availset.tf

resource "azurerm_availability_set" "web_as" {
  name                = var.availability_set_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  managed = true

  # Optional tuning; keep or remove as you prefer
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count

  # If you removed project_name, either drop tags entirely or use RG name for tagging
  tags = {
    OwnerRG = var.resource_group_name
    Role    = "web"
  }
}
