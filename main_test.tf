resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
}

resource "azurerm_monitor_action_group" "main" {
  name                = "example-actiongroup"
  resource_group_name = var.resource_group_name
  short_name          = var.short_name

  webhook_receiver {
    name        = "azurealertapi"
    service_uri = "http://example.com/alert" #need actual URI to change  #Email address to receive alerts?
  }
}

resource "azurerm_storage_account" "to_monitor" {
  name                     = "azure_sa"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "GRS"  #could also be GZRS or LRS (https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy) 
}

resource "azurerm_monitor_activity_log_alert" "main" {
  name                = "azure-activitylogalert"
  resource_group_name = azurerm_resource_group.this.name
  scopes              = [azurerm_resource_group.this.id]   #are scopes separately defined?
  description         = "This alert will monitor specific Azure Alerts for Service Desk"

  criteria {
    resource_id    = azurerm_storage_account.to_monitor.id
    operation_name = "Microsoft.Storage/storageAccounts/write"  #should be changed?
    category       = "ServiceHealth"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id

 

    webhook_properties = {
      from = "terraform"
    }
  }
}

# webhook auf email_receiver
# from criteria -> category "ServiceHealth" -> dann unterblock machen mit services, usw. from Azure (Beispiel from Tassilo (Health Alerts -> Properties -> JSON view))
# Azure Provider block, damit validation durchläuft
