# Example resizing PBC without downtime
* Install Azure Disk CSI Driver  
  * https://learn.microsoft.com/en-us/azure/aks/csi-storage-drivers
* Apply the the original claim
---
    kubectl apply -f .\01-disk-pvc.yaml
---
* Create the deployment

---
    kubectl apply -f .\02-deployment.yaml
---

* Update the original claim

---
     kubectl apply -f .\03-disk-pvc-resize.yaml
---

**Note**
If you decrease the capacity then there will be an error
