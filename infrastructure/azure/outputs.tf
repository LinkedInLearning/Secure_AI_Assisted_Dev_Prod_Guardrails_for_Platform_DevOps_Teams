output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.sensor_data.name
}

output "servicebus_namespace" {
  description = "Service Bus namespace name"
  value       = azurerm_servicebus_namespace.events.name
}

output "function_app_name" {
  description = "Function App name"
  value       = azurerm_linux_function_app.sensor_processor.name
}
