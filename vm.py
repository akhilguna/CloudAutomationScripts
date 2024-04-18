import os

# Define your resource groups, locations, VM names, admin username, and admin password
rg_location = {
    "myResourceGroup1": "East US",
    "myResourceGroup2": "West Europe"
}

vm_names = {
    "myResourceGroup1": ["VM1", "VM2"],
    "myResourceGroup2": ["VM3", "VM4"]
}

adminUsername = "netrich"
adminPassword = "netrich@1234"

# Loop through the resource groups and locations
for rg, location in rg_location.items():
    vms = vm_names[rg]

    # Create a resource group in the specified location
    os.system(f"az group create --name {rg} --location \"{location}\" --output none")

    # Loop through the VM names for each resource group
    for vm in vms:
        # Create the VM in the specified location
        os.system(f"az vm create "
                  f"--resource-group {rg} "
                  f"--name {vm} "
                  f"--image Ubuntu2204 "
                #   f"--image MicrosoftWindowsServer:WindowsServer:2022-Datacenter:latest"
                  f"--admin-username {adminUsername} "
                  f"--admin-password {adminPassword} "
                  f"--authentication-type password "
                  f"--output none")
