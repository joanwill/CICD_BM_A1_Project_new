provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_app_service_plan" "plan" {
  name                = "todo-api-plan"
  location            = var.location
  resource_group_name = "bm-a1cidcproject"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}





