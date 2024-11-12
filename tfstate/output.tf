output "primary_access_key" {
  value = azurerm_storage_account.terraform_state.primary_access_key
  sensitive = true
}