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

resource "azurerm_container_registry" "prod-acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.prod-rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_app_service" "prod-webapp" {
  name                = var.webapp_name
  location            = var.location
  resource_group_name = azurerm_resource_group.prod-rg.name
  app_service_plan_id = azurerm_app_service_plan.prod-plan.id

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.prod-acr.login_server}/todo-backend-api:latest"
  }

  app_settings = {
    WEBSITES_PORT = "80"
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.prod-acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr.admin_password
  }
}
