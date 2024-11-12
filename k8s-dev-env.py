from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.compute.models import VirtualMachine, HardwareProfile, StorageProfile, OSDisk, ImageReference, OSProfile, NetworkInterfaceReference, LinuxConfiguration, SshConfiguration, SshPublicKey
from azure.mgmt.network.models import PublicIPAddress, NetworkInterface, NetworkInterfaceIPConfiguration, NetworkSecurityGroup, SecurityRule, VirtualNetwork, Subnet
import os
from dotenv import load_dotenv

load_dotenv()

SUBSCRIPTION_ID     = os.getenv("AZ_SUBSCRIPTION_ID")
RESOURCE_GROUP_NAME = os.getenv("AZ_RESOURCE_GROUP_NAME")
LOCATION            = os.getenv("AZ_LOCATION_NAME")
VM_NAME             = os.getenv("AZ_VM_NAME")
VNET_NAME           = os.getenv("AZ_VNET_NAME")
SUBNET_NAME         = os.getenv("AZ_SUBNET_NAME")
PUBLIC_IP_NAME      = os.getenv("AZ_PUBLIC_IP_NAME")
NIC_NAME            = os.getenv("AZ_NIC_NAME")
NIC_CONFIG          = os.getenv("AZ_NIC_CONFIG")
ADMIN_USER          = os.getenv("AZ_VM_ADMIN_USER")
ADMIN_PASS          = os.getenv("AZ_VM_ADMIN_PASS")

# verification that configuration is correct.
print(f"subscription_id = {SUBSCRIPTION_ID}")
print(f"RESOURCE_GROUP_NAME = {RESOURCE_GROUP_NAME}")
print(f"LOCATION = {LOCATION}")
print(f"VM_NAME = {VM_NAME}")
print(f"VNET_NAME = {VNET_NAME}")
print(f"SUBNET_NAME = {SUBNET_NAME}")
print(f"PUBLIC_IP_NAME = {PUBLIC_IP_NAME}")
print(f"NIC_NAME = {NIC_NAME}")
print(f"NIC_CONFIG = {NIC_CONFIG}")
print(f"ADMIN_USER = {ADMIN_USER}")
print(f"ADMIN_PASS = {ADMIN_PASS}")

# Define your Azure subscription ID
subscription_id = SUBSCRIPTION_ID

# Authentication
credential = DefaultAzureCredential()

# Resource client for creating a resource group
resource_client = ResourceManagementClient(credential, subscription_id)

# Compute client for creating VMs
compute_client  = ComputeManagementClient(credential, subscription_id)

# Network client for creating networking components
network_client  = NetworkManagementClient(credential, subscription_id)

# Define the resource group, location, and VM name
resource_group_name = RESOURCE_GROUP_NAME
location            = LOCATION
vm_name             = VM_NAME

# Create a resource group
resource_client.resource_groups.create_or_update(resource_group_name, {'location': location})

# Create a virtual network
vnet_name   = VNET_NAME
vnet_params = VirtualNetwork(
    location=location,
    address_space={'address_prefixes': ['10.0.0.0/16']}
)
vnet_result = network_client.virtual_networks.begin_create_or_update(
    resource_group_name,
    vnet_name,
    vnet_params
).result()

# Create a subnet
subnet_name   = SUBNET_NAME
subnet_result = network_client.subnets.begin_create_or_update(
    resource_group_name,
    vnet_name,
    subnet_name,
    {'address_prefix': '10.0.0.0/24'}
).result()

# Create a public IP address
ip_name   = PUBLIC_IP_NAME
ip_params = PublicIPAddress(
    location=location,
    public_ip_allocation_method='Dynamic'
)
public_ip_result = network_client.public_ip_addresses.begin_create_or_update(
    resource_group_name,
    ip_name,
    ip_params
).result()

# Create a network interface
nic_name   = NIC_NAME
nic_params = NetworkInterface(
    location=location,
    ip_configurations=[{
        'name': NIC_CONFIG,
        'subnet': {'id': subnet_result.id},
        'public_ip_address': {'id': public_ip_result.id}
    }]
)
nic_result = network_client.network_interfaces.begin_create_or_update(
    resource_group_name,
    nic_name,
    nic_params
).result()

# Specify the VM configuration
vm_params = VirtualMachine(
    location=location,
    hardware_profile=HardwareProfile(vm_size='Standard_DS3_v2'),
    storage_profile=StorageProfile(
        image_reference=ImageReference(
            publisher='Canonical',
            offer='UbuntuServer',
            sku='18.04-LTS',
            version='latest'
        ),
        os_disk=OSDisk(
            create_option='FromImage',
            managed_disk={'storage_account_type': 'Standard_LRS'},
            disk_size_gb=30
        )
    ),
    os_profile=OSProfile(
        computer_name=vm_name,
        admin_username=ADMIN_USER,
        admin_password=ADMIN_PASS  # Replace with a secure password
    ),
    network_profile={
        'network_interfaces': [NetworkInterfaceReference(id=nic_result.id)]
    }
)

# Create the VM
vm_result = compute_client.virtual_machines.begin_create_or_update(
    resource_group_name,
    vm_name,
    vm_params
).result()

print(f"VM {vm_name} created successfully with public IP: {public_ip_result.ip_address}")
