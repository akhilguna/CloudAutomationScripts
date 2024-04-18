# Ensure you have the Azure PowerShell module installed and imported
Import-Module Az

# Login to Azure (if not already logged in)
# Connect-AzAccount

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
$adminPassword = ConvertTo-SecureString "netrich@1234" -AsPlainText -Force

# Loop through the resource groups and locations
# Loop through the resource groups and locations
foreach ($rg in $rg_location.Keys) {
    $location = $rg_location[$rg]
    $vms = $vm_names[$rg]

    # Create a resource group in the specified location
    New-AzResourceGroup -Name $rg -Location $location

    # Loop through the VM names for each resource group
    foreach ($vm in $vms) {
        # Create a subnet configuration
        $subnetConfig = New-AzVirtualNetworkSubnetConfig -Name "$vm-Subnet" -AddressPrefix "10.0.0.0/24"

        # Create a virtual network
        $vnet = New-AzVirtualNetwork -Name "$vm-VNet" -ResourceGroupName $rg -Location $location -AddressPrefix "10.0.0.0/16" -Subnet $subnetConfig

        # Create a public IP address
        $pip = New-AzPublicIpAddress -Name "$vm-Pip" -ResourceGroupName $rg -Location $location -AllocationMethod Dynamic

        # Create a network security group
        $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $rg -Location $location -Name "$vm-NSG"

        # Create a network interface
        $nic = New-AzNetworkInterface -Name "$vm-NIC" -ResourceGroupName $rg -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

        # Create the VM configuration
        $vmConfig = New-AzVMConfig -VMName $vm -VMSize "Standard_DS1_v2"
        $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vm -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword))
        $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest"
        # $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-Datacenter" -Version "latest"
        $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

        # Create the VM in the specified location
        New-AzVM -ResourceGroupName $rg -Location $location -VM $vmConfig
    }
}

