# Running Self Host Agent In Azure Container Instance 
# How to build container image using containerised agent

This POC demonstrated building container image using Azure DevOps self host agent on Azure Container Instances with Azure Container Registry with disable public access.

Update the parameter file to 
```
using './resource.bicep'

param AZP_URL = '' // DevOps URL
param AZP_TOKEN = ''// PAT Token for the Azure DevOps
param GIT_TOKEN = '' // GitHub PAT Token
param GIT_REPO = '' // GitHub URL

```
Run the command to deploy the resournce
``` bicep
  az group create -n <resource-group-name> -l <localtion>
az deployment group create --template-file main.bicep -g <resource-group-name> --parameters main.local.bicepparam
```