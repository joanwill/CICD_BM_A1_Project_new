provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "prod-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_app_service_plan" "prod-plan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = azurerm_resource_group.prod-rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}
