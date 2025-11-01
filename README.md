# Fancy TODO — Flutter + ASP.NET Core + Cosmos DB

A demo app designed to meet the rubric: two components (Flutter frontend + C# Web API), CI/CD with Azure DevOps, Docker, Terraform, two environments (Dev/Prod), and tests (unit + integration).

> ⚠️ You must fill in your Azure Subscription IDs, resource names, and ACR login in the pipeline variables. This template gives you a working starting point.

## Components
- **Backend**: ASP.NET Core 8 Minimal API (`/backend`) with Cosmos DB SDK.
- **Frontend**: Flutter (Material 3) (`/frontend`) with REST client.
- **Infra**: Terraform modules to provision Cosmos DB, ACR, App Service for container, and Storage Static Website (`/infra/terraform`).
- **CI/CD**: Azure DevOps multi-stage pipeline (`/.azure-pipelines/azure-pipelines.yml`).

## Quick Start (Local Dev)
1. **Backend**  
   ```bash
   cd backend
   dotnet restore
   dotnet run
   ```
   The API runs on `http://localhost:5199` (see `Properties/launchSettings.json`).

2. **Frontend (Web)**  
   ```bash
   cd frontend/fancy_todo
   flutter pub get
   flutter run -d chrome
   ```
   Update `lib/services/api_client.dart` baseUrl if needed.

3. **Docker (Optional)**  
   ```bash
   docker build -t fancy-todo-api:dev ./backend
   docker run -p 5199:8080 -e ASPNETCORE_URLS=http://+:8080 fancy-todo-api:dev
   ```

## Tests
- **Backend**: `dotnet test` runs xUnit unit & integration tests.
- **Frontend**: `flutter test` runs Dart unit & widget tests.

## CI/CD
- On push, pipeline builds, tests, creates Docker images, and publishes artifacts.
- **Dev** deploys automatically with Terraform.
- **Prod** requires manual approval.

> Configure variable group or pipeline variables:
- `AZ_SUBSCRIPTION_ID`, `AZ_RESOURCE_GROUP_DEV`, `AZ_RESOURCE_GROUP_PROD`
- `AZ_LOCATION` (e.g. `westeurope`)
- `ACR_NAME_DEV`, `ACR_NAME_PROD`
- `COSMOS_ACCOUNT_DEV`, `COSMOS_ACCOUNT_PROD`
- `APP_NAME_DEV`, `APP_NAME_PROD`
- `STORAGE_NAME_DEV`, `STORAGE_NAME_PROD`
- `SERVICE_CONNECTION` (AzureRM service connection name)
- `DOCKER_IMAGE_NAME` (e.g. `fancy-todo-api`)

## API
- `GET /api/todos`
- `GET /api/todos/{id}`
- `POST /api/todos`
- `PUT /api/todos/{id}`
- `DELETE /api/todos/{id}`

## Agile/Docs
See `/docs/PROJECT_TEMPLATE.md` for a fill-in template and `/docs/presentation.pptx` starter slides.

---
MIT License
