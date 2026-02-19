## Summary
Provision all Azure resources as infrastructure for the ZavaStorefront web
application (dev environment) into a single resource group in westus3. Use
Bicep files and AZD to define and deploy all resources together. Application to
be deployed as a Docker container to Linux App Service (Web App for
Containers), without requiring local Docker. App Service will pull images from
Azure Container Registry (ACR) using Azure RBAC and managed identity (no
password secrets). The application will be monitored using Application
Insights. Microsoft Foundry will also be provisioned for GPT-4 and Phi access in
westus3 as these models are available there.

## Requirements
- All resources provisioned into a single resource group (e.g. `rg-zavastore-dev-westus3`) in westus3
- Azure Container Registry (ACR) for container images (SKU: Basic/Standard)
- Linux App Service (Web App for Containers) configured to pull images from ACR
- System-assigned managed identity for Web App, with AcrPull role assignment to ACR
- No password-based pulls from ACR
- Application Insights instance linked for monitoring
- Microsoft Foundry resource provisioned in westus3
- All resources defined in Bicep templates and provisioned with AZD
- No local Docker required: Image builds/pushes use az acr build or GitHub Actions (run in cloud)
- Minimal-cost SKUs appropriate for dev

## Implementation Guidance
- Use modular Bicep structure (`infra/` folder with modules for ACR, App Service Plan, Web App, App Insights, Microsoft Foundry, and role assignments)
- Parameterize resource names, region, environment, SKUs in Bicep
- `azd.yaml` and README should document full deployment/dev workflow
- CI workflow examples for image build/push without local Docker (cloud builds)
- Role assignment in Bicep: Assign `AcrPull` on ACR to App Service managed identity
- Application Insights: Connect via instrumentation key/app settings
- Microsoft Foundry: Use dev-appropriate SKUs; ensure region supports requested models

## Checklist
- [ ] Confirm region and subscription quotas for Microsoft Foundry in westus3
- [ ] Bicep modules for ACR, App Service, App Insights, Role Assignment, Microsoft Foundry
- [ ] Main Bicep template (calls modules)
- [ ] azd.yaml script (maps provision/deploy workflow)
- [ ] GitHub Actions workflow for ACR build (cloud-side or hosted runner)
- [ ] AcrPull role assignment (managed identity)
- [ ] App Insights wiring
- [ ] Microsoft Foundry deployment and configuration
- [ ] README.md with workflow/cost notes
- [ ] Smoke test: app deploy/monitoring/AI access

---
If you need code/starter templates for Bicep or CI workflow, request below.

