
############################################
# Storage Account (GRS) for state + logs
# - Public network access enabled
# - Only Management subnet allowed via VNet rules
############################################

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type

  # Network rules: allow only the Management subnet
  network_rules {
    default_action             = "Deny"            # deny everyone by default
    bypass                     = ["AzureServices"] # permit Azure platform services where needed
    virtual_network_subnet_ids = [azurerm_subnet.subnet_mgmt.id]
    # You can add ip_rules = ["x.x.x.x"] if you also need an admin exception from a public IP
  }

  # (Optional but recommended) enforce HTTPS
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  tags = {
    OwnerRG = var.resource_group_name
    Role    = "storage"
  }
}

############################################
# Blob containers
############################################

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.storage_containers)
  name                  = each.key
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}
