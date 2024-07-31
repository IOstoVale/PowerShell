# Start with creating a new resource group in Azure
# Pre is that the AZ module is installed, this is done by installing the module as follows:
# Install-Module -Name Az -Repository PSGallery -Force
# In VS Code make sure PowerShell 7 is installed and the default profile, otherwise the Az module
# fails.
New-AzResourceGroup -Name VM_RG01 -Location "westeurope"
# Next, create a new vnet
$VMVnet01 = New-AzVirtualNetwork -ResourceGroupName VM_RG01 -Location westeurope -Name VMVNET01 -AddressPrefix 10.0.0.0/16
# A subnet must be created to facilitate the VM's
$frontendSubnet = New-AzVirtualNetworkSubnetConfig -Name VirtualMachineSubnet -AddressPrefix "10.0.1.0/24"