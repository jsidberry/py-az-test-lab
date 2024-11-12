# This creates a RHEL9 VM into existing VNET and SUBNET,
# and uses existing NSG.
# Step for clarity:
# (1) get data for existing VNET & SUB
# (2) get data for existing NSG
# (3) create a Public IP (PIP)
# (4) create a NIC
# (5) create a associate NIC with NSG
# (6) create the VM, this pulls in a shell script that installs wanted services

# data "azurerm_key_vault" "existing" {
#   name                = "your-key-vault-name"
#   resource_group_name = "your-resource-group-name"
# }

# data "azurerm_key_vault_secret" "example" {
#   name         = "your-secret-name"
#   key_vault_id = data.azurerm_key_vault.existing.id
# }

# output "secret_value" {
#   value = data.azurerm_key_vault_secret.example.value
#   sensitive = true
# }

resource "azurerm_resource_group" "rg" {
  name     = "${var.tier[0]}-${var.region}-rg-${var.app}-001"
  location = var.loc
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.tier[0]}-${var.region}-vnet-${var.app}-001"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.tier[0]}-${var.region}-sn-${var.app}-001"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.tier[0]}-${var.region}-nsg-${var.app}-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.tier[0]}-${var.region}-vm-${var.app}-001-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create network interface
resource "azurerm_network_interface" "poc_nic" {
  name                = "${var.tier[0]}-${var.region}-vm-${var.app}-001-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.tier[0]}-${var.region}-vm-${var.app}-001-nic-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  depends_on = [azurerm_public_ip.public_ip]
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.poc_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_machine" "vm" {
  name                             = "${var.tier[0]}-${var.region}-vm-${var.app}-001"
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  vm_size                          = "Standard_D2s_v3"
  network_interface_ids            = [azurerm_network_interface.poc_nic.id]
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "os_disk_ubuntu"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # must figure out how to pull in sensitive values
  os_profile {
    computer_name  = "${var.tier[0]}-${var.region}-vm-${var.app}-001"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = base64encode(file("files/init-k8s.sh"))
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  connection {
    type = "ssh"
    user = var.admin_username
    host = azurerm_public_ip.public_ip.ip_address
  }

  depends_on = [azurerm_network_interface.poc_nic]
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}