# Running Self Host Agent In Azure Container Instance 
# How to build container image using containerised agent

This POC demonstrated building container image using Azure DevOps self host agent on Azure Container Instances with Azure Container Registry with disable public access.

Update the parameter file to 
```
using './main.bicep'

param AZP_URL = '' // DevOps URL
param AZP_TOKEN = ''// PAT Token for the Azure DevOps
param GIT_TOKEN = '' // GitHub PAT Token
param GIT_REPO = '' // GitHub URL

```
Run the command to deploy the resournce
``` bicep
az group create -n <resource-group-name> -l <location>
az deployment group create --template-file main.bicep -g <resource-group-name> --parameters main.bicepparam
```
Connect to the self host agent command line
Run the command to trigger Azure Container Registry Task Build
``` cli
az login --identity
az acr task run --resource-group <resource-grou-name> --registry <acr-name> --name build-task
``` 
