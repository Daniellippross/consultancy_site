resource "azurerm_resource_group" "rg" {
  name     = "site-rg"
  location = "UK South"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "site-vnet" # CHANGE
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "site-subnet" # CHANGE
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/23"]

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
}

resource "azurerm_network_interface" "nic" {
  name                = "site-nic" # CHANGE
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1" # CHANGE
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

resource "azurerm_public_ip" "ip" {
  name                = "site-pub-ip" # CHANGE
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "site-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "siteinboundrule1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "workspacesiterg83b4"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "aca_env" {
  name                       = "site-managed-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  infrastructure_subnet_id   = azurerm_subnet.internal.id
}

resource "azurerm_container_app" "aca" {
  name                         = "aca-site"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  secret {
    name = "test"
    value = "test"
  }

  ingress {
    external_enabled = true
    target_port = "80"
    traffic_weight {
      latest_revision = true
      percentage = "100"
    }
  }

  template {
    max_replicas = 1
    container {
      name   = "aca-site"
      image  = "lipprossconsultancy.azurecr.io/consultancy/site:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
  lifecycle {
    ignore_changes = [ secret, registry ]
  }
}