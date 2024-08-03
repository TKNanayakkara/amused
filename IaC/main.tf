provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "aks_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.aks_rg.name
  location                 = azurerm_resource_group.aks_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks_log_analytics" {
  name                = var.log_analytics_workspace_name
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_log_analytics.id
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "development"
  }
}

# AKS Credentials
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}

# Azure Blob Storage for Persistent Volumes
resource "azurerm_storage_container" "aks_blob_container" {
  name                  = "aksblobcontainer"
  storage_account_name  = azurerm_storage_account.aks_storage.name
  container_access_type = "private"
}

# Azure Container Registry
resource "azurerm_container_registry" "aks_acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Assign AKS to ACR
resource "azurerm_role_assignment" "aks_acr_assignment" {
  scope                = azurerm_container_registry.aks_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
}
