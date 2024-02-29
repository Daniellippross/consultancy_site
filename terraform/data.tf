data "azurerm_key_vault" "kv" {
  name                = "lippross-management-kv"
  resource_group_name = "management-rg"
}

data "azurerm_key_vault_secret" "pub-ssh-key" {
  name         = "site-vm-pub-ssh-key"
  key_vault_id = data.azurerm_key_vault.kv.id
}