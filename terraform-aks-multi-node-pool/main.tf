terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.38.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "exampleaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin = "azure"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "windows" {
  name                  = "win"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
  vm_size               = "Standard_D2_v2"
  node_count            = 1
  os_type               = "Windows"
}

resource "azurerm_kubernetes_cluster_node_pool" "linux" {
  name                  = "linuxpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
  vm_size               = "Standard_D2_v2"
  node_count            = 1
  os_type               = "Linux"
}