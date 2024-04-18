# Login to Azure (if not already logged in)
# az login --use-device-code

# Define your resource groups, locations, VM names, admin username, and admin password
$rg_location = @{
    "myResourceGroup1" = "East US"
    "myResourceGroup2" = "West Europe"
}

$vm_names = @{
    "myResourceGroup1" = @("VM1", "VM2")
    "myResourceGroup2" = @("VM3", "VM4")
}

$adminUsername = "netrich"
$adminPassword = "netrich@1234"

    # Loop through the resource groups and locations
    foreach ($rg in $rg_location.Keys) {
        $location = $rg_location[$rg]
        $vms = $vm_names[$rg]

        # Create a resource group in the specified location
        az group create --name $rg --location $location --output none

        # Loop through the VM names for each resource group
        foreach ($vm in $vms) {
            # Create the VM in the specified location
            az vm create `
                --resource-group $rg `
                --name $vm `
                --image Ubuntu2204 `
                --admin-username $adminUsername `
                --admin-password $adminPassword `
                --authentication-type password `
                --output none
        }
    }


$adminUsername = "netrich"
$adminPassword = "netrich@1234"

# Loop through the resource groups and locations
foreach ($rg in $rg_location.Keys) {
    $location = $rg_location[$rg]
    $vms = $vm_names[$rg]

    # Create a resource group in the specified location
    az group create --name $rg --location $location --output none

    # Loop through the VM names for each resource group
    foreach ($vm in $vms) {
        # Create the VM in the specified location
        az vm create `
            --resource-group $rg `
            --name $vm `
            --image Win2022Datacenter `
            --admin-username $adminUsername `
            --admin-password $adminPassword `
            --authentication-type password `
            --output none
    }
}