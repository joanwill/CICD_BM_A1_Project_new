resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmos_account
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "todo"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

resource "azurerm_cosmosdb_sql_container" "todos" {
  name                = "Todos"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_path  = "/userId"
}

resource "azurerm_service_plan" "plan" {
  name                = "${var.app_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.acr.login_server}/${var.docker_image_name}"
      docker_image_tag = var.docker_image_tag
    }
  }

  app_settings = {
    WEBSITES_PORT            = "8080"
    ASPNETCORE_URLS          = "http://+:8080"
    COSMOS_DB_ENDPOINT       = azurerm_cosmosdb_account.cosmos.endpoint
    COSMOS_DB_KEY            = azurerm_cosmosdb_account.cosmos.primary_key
    COSMOS_DB_DATABASE       = azurerm_cosmosdb_sql_database.db.name
    COSMOS_DB_CONTAINER      = azurerm_cosmosdb_sql_container.todos.name
    CORS__AllowedOrigins__0  = "*"
  }
}

resource "azurerm_storage_account" "static" {
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_account_static_website" "site" {
  storage_account_id = azurerm_storage_account.static.id
  index_document     = "index.html"
  error_404_document = "index.html"
}

output "api_url" {
  value = azurerm_linux_web_app.app.default_hostname
}
output "static_website_url" {
  value = azurerm_storage_account_static_website.site.primary_endpoint
}
