# Running Self Host Agent In Azure Container Instance 
# How to build container image using containerised agent

This POC demonstrated building container image using Azure DevOps self host agent on Azure Container Instances with Azure Container Registry with disable public access.

``` bicep
  az group create -n <resource-group-name> -l <localtion>
az deployment group create --template-file resource.bicep -g rg-temp-5 --parameters resource.local.bicepparam
```