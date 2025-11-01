# Project Documentation Template

## 1. Project Overview
- **Goal**: Fancy TODO app with Flutter frontend, ASP.NET Core API, Cosmos DB, and full CI/CD.
- **Screenshot(s)**: _Add here_
- **Repo & Branching**: _Add link; describe branching strategy_

## 2. Architecture
- **Components**: Frontend (Flutter web), Backend (ASP.NET Core), Cosmos DB (SQL API)
- **Diagram**: _Add diagram_
- **Key Decisions**:
  - Minimal API for speed
  - Cosmos DB Serverless + partition on `/userId`
  - Azure DevOps pipelines with Terraform
  - Docker images for backend, static site for frontend

## 3. Iterative Development (Agile)
- **Iterations (1–2 weeks)**: _List goals per iteration_
- **Kanban Board**: _Screenshot of Trello/GitHub Projects_
- **Reflection After Each Iteration**: _What changed and why_

## 4. CI/CD Pipeline
- **Build/Test**: dotnet + flutter
- **Artifacts**: Docker image + frontend web files
- **Deploy**: Terraform to Dev (auto), Prod (manual approval)
- **Diagram**: _Add diagram_

## 5. Testing
- **Unit Tests**: C# validator tests, Dart model tests
- **Integration Tests**: API endpoints via TestServer
- **How to run**: `dotnet test`, `flutter test`

## 6. Docker
- **Backend**: ASP.NET 8 image
- **Frontend**: Built to static files; optional nginx image
- **Compose (optional)**: _Add if used_

## 7. Infrastructure (Terraform)
- **Resources**: RG, ACR, Cosmos, App Service (linux), Storage Static Website
- **Variables**: See pipeline variables
- **State**: Local by default (configure remote if desired)

## 8. Challenges & Solutions
- _e.g., Cosmos emulator limitations; used in-memory for tests_

## 9. Work Log
- **Date / Task / Notes**: _Fill as you go_

## 10. Lessons Learned
- _E.g., importance of small increments, automated tests_

## 11. Live Demo Plan
- Deploy new change -> watch pipeline -> refresh web app
