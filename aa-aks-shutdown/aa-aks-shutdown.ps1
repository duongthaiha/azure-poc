try{
Connect-AzAccount -Subscription xxxdentity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}
# Get all AKS clusters
$aksClusters = Get-AzAksCluster -SubscriptionId 29d43490-9ab4-4153-b918-9b56541f1048

# Loop through each cluster and stop it
foreach ($cluster in $aksClusters) {
    Write-Host "Stopping AKS cluster $($cluster.Name) in resource group $($cluster.ResourceGroupName)..."
    Stop-AzAksCluster -Name $cluster.Name -ResourceGroupName $cluster.ResourceGroupName -Confirm:$false
}

# Output a message indicating that all clusters have been stopped
Write-Host "All AKS clusters have been stopped."