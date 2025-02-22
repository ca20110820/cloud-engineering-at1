resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# =========================== Networking
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_prefix]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefix]
}

# --------------------------- NSGs
resource "azurerm_network_security_group" "nsg" {
  name                = "at1-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# NSG Security Rules (RDP for Windows and SSH for Linux)
resource "azurerm_network_security_rule" "rdp_rule" {
  resource_group_name         = azurerm_resource_group.rg.name
  name                        = "Allow-RDP"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"  # RDP port
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "ssh_rule" {
  resource_group_name         = azurerm_resource_group.rg.name
  name                        = "Allow-SSH"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"    # SSH port
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# =========================== Virtual Machines
resource "azurerm_windows_virtual_machine" "win10" {
  name                = "win10"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.win10_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-pro"
    version   = "latest"
  }

  zone = "1"
}

resource "azurerm_windows_virtual_machine" "winserver22" {
  name                = "winserver22"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.winserver22_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  zone = "1"
}

resource "azurerm_linux_virtual_machine" "linuxserver" {
  name                = "linuxserver"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.linuxserver_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy-daily"
    sku       = "22_04-daily-lts-gen2"
    version   = "22.04.202502190"
  }

  zone = "1"

  disable_password_authentication = false
}

# --------------------------- VM NICs
resource "azurerm_network_interface" "win10_nic" {
  name                = "win10-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.win10_pip.id
  }
}

resource "azurerm_network_interface" "winserver22_nic" {
  name                = "winserver22-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.winserver22_pip.id
  }
}

resource "azurerm_network_interface" "linuxserver_nic" {
  name                = "linuxserver-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linuxserver_pip.id
  }
}

# Associate NSG with NICs
resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  for_each = {
    win10_nic       = azurerm_network_interface.win10_nic.id
    winserver22_nic = azurerm_network_interface.winserver22_nic.id
    linuxserver_nic = azurerm_network_interface.linuxserver_nic.id
  }

  network_interface_id      = each.value
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# --------------------------- VM Public IPs
resource "azurerm_public_ip" "win10_pip" {
  name                = "win10-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "winserver22_pip" {
  name                = "winserver22-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "linuxserver_pip" {
  name                = "linuxserver-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# =========================== Runtime Configurations
# Enable ICMP (Ping) rules for both incoming and outgoing traffic for Windows VMs
locals {
  windows_vms = {
    win10       = azurerm_windows_virtual_machine.win10.id
    winserver22 = azurerm_windows_virtual_machine.winserver22.id
  }

  custom_script = <<EOT
powershell.exe -Command "Write-Output 'Hello from Terraform!' | Out-File C:\\terraform-output.txt; New-NetFirewallRule -DisplayName 'Allow ICMPv4-In' -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow -Direction Inbound; New-NetFirewallRule -DisplayName 'Allow ICMPv4-Out' -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow -Direction Outbound;"
EOT
}

resource "azurerm_virtual_machine_extension" "windows_custom_script" {
  for_each             = local.windows_vms
  name                 = "${each.key}-custom-script"
  virtual_machine_id   = each.value
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = local.custom_script
  })
}

resource "azurerm_virtual_machine_extension" "linuxserver_custom_script" {
  name                 = "linuxserver-custom-script"
  virtual_machine_id   = azurerm_linux_virtual_machine.linuxserver.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  settings = <<SETTINGS
    {
      "commandToExecute": "echo 'Hello World' > /tmp/hello_world.txt"
    }
  SETTINGS
}
