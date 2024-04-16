# Login to Azure (Uncomment the next line if you need to login or switch accounts)
# az login

# Set Variables
$resourceGroupName = "devsecops"
$location = "northeurope"
$aksClusterName = "Devsecops-aks"
$aksVersion = "1.29.0"

# Create Resource Group if it doesn't exist
$resourceGroupExists = az group exists --name $resourceGroupName
if (-not $resourceGroupExists) {
    Write-Output "Creating resource group '$resourceGroupName' in location '$location'."
    az group create --name $resourceGroupName --location $location
} else {
    Write-Output "Resource group '$resourceGroupName' already exists."
}

# Create AKS Cluster
Write-Output "Creating AKS cluster named '$aksClusterName' in resource group '$resourceGroupName'."
az aks create `
  --resource-group $resourceGroupName `
  --name $aksClusterName `
  --node-count 1 `
  --enable-addons monitoring `
  --kubernetes-version $aksVersion `
  --generate-ssh-keys `
  --location $location `
  --node-vm-size Standard_B2s `
  --load-balancer-sku basic `
  --no-wait

Write-Output "AKS cluster creation command has been executed. It may take a few minutes for the cluster to be fully operational."
