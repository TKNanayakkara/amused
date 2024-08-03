variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "aks-rg-dev"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the Azure storage account"
  type        = string
  default     = "aksstorageaccount"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "aks-log-analytics-dev"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-cluster-dev"
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the VM for AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aksdns"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "aksacrdev"
}
