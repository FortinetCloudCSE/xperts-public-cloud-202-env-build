locals {

  user_common = {
    user_principal_domain = var.user_principal_domain
    display_name_ext      = var.username
    password              = var.password
    usage_location        = "US"
    account_enabled       = true
  }

  # Linux VM Image and Size
  linux_vm_image = {
    size      = "Standard_F2"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  virtual_wans = {
    "vwan" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "${var.username}-${var.rg_suffix}_VWAN"
    }
  }

  virtual_hubs = {
    "vHub1" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name           = "${var.username}-${azurerm_resource_group.resource_group.location}_vHub1_VHUB"
      address_prefix = "10.1.0.0/16"
      virtual_wan_id = azurerm_virtual_wan.virtual_vwan["vwan"].id
    }
  }

  virtual_networks = {
    "Spoke1-vHub1_VNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name          = "Spoke1-vHub1_VNET"
      address_space = ["192.168.1.0/24"]
    }
    "Spoke2-vHub1_VNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name          = "Spoke2-vHub1_VNET"
      address_space = ["192.168.2.0/24"]
    }
  }

  subnets = {
    "Spoke1-vhub1_SUBNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name                 = "Spoke1-vhub1_SUBNET"
      address_prefix       = ["192.168.1.0/24"]
      virtual_network_name = azurerm_virtual_network.virtual_network["Spoke1-vHub1_VNET"].name
    }
    "Spoke2-vhub1_SUBNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name                 = "Spoke2-vhub1_SUBNET"
      address_prefix       = ["192.168.2.0/24"]
      virtual_network_name = azurerm_virtual_network.virtual_network["Spoke2-vHub1_VNET"].name
    }
  }

  network_interfaces = {
    "Linux-Spoke1-VM_nic1" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "Linux-Spoke1-VM_nic1"
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["Spoke1-vhub1_SUBNET"].id
          private_ip_address_allocation = "Dynamic"
          public_ip_address_id          = null
        }
      ]
    }
    "Linux-Spoke2-VM_nic1" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "Linux-Spoke2-VM_nic1"
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["Spoke2-vhub1_SUBNET"].id
          private_ip_address_allocation = "Dynamic"
          public_ip_address_id          = null
        }
      ]
    }
  }

  linux_virtual_machines = {
    "Linux-Spoke1-VM" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "Linux-Spoke1-VM"
      network_interface_ids = [
        azurerm_network_interface.network_interface["Linux-Spoke1-VM_nic1"].id,
      ]
      os_disk_name                 = "Linux-Spoke1-VM-OSDisk"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"

      custom_data = base64encode(<<-EOF
        #cloud-config
        package_upgrade: true
        packages:
          - apache2
        runcmd:
          - sudo git clone https://github.com/movinalot/fortigate-demo-files.git
          - sudo cat fortigate-demo-files/index.html | sed "s/machine-name/Linux-Spoke1-VM/g" > index.html
          - sudo mv index.html fortigate-demo-files/index.html
          - sudo cp -r fortigate-demo-files/* /var/www/html/
        EOF
      )
    }
    "Linux-Spoke2-VM" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "Linux-Spoke2-VM"
      network_interface_ids = [
        azurerm_network_interface.network_interface["Linux-Spoke2-VM_nic1"].id,
      ]
      os_disk_name                 = "Linux-Spoke2-VM-OSDisk"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"

      custom_data = base64encode(<<-EOF
        #cloud-config
        package_upgrade: true
        packages:
          - apache2
        runcmd:
          - sudo git clone https://github.com/movinalot/fortigate-demo-files.git
          - sudo cat fortigate-demo-files/index.html | sed "s/machine-name/Linux-Spoke2-VM/g" > index.html
          - sudo mv index.html fortigate-demo-files/index.html
          - sudo cp -r fortigate-demo-files/* /var/www/html/
        EOF
      )
    }
  }
}

resource "azuread_user" "user" {

  user_principal_name = format("%s%s", var.username, local.user_common["user_principal_domain"])
  display_name        = var.username
  mail_nickname       = format("%s%s", var.username, local.user_common["display_name_ext"])
  mail                = format("%s%s", var.username, local.user_common["user_principal_domain"])
  password            = local.user_common["password"]
  account_enabled     = local.user_common["account_enabled"]
  usage_location      = local.user_common["usage_location"]
}

resource "azuread_group_member" "group_member" {

  group_object_id  = var.public_cloud_202_group_object_id
  member_object_id = azuread_user.user.object_id
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.username}-${var.rg_suffix}"
  location = var.location

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "virtual_network" {
  for_each = local.virtual_networks

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name          = each.value.name
  address_space = each.value.address_space
}

resource "azurerm_subnet" "subnet" {
  for_each = local.subnets

  resource_group_name = each.value.resource_group_name

  name                 = each.value.name
  address_prefixes     = each.value.address_prefix
  virtual_network_name = each.value.virtual_network_name
}

resource "azurerm_network_interface" "network_interface" {
  for_each = local.network_interfaces

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations
    content {
      name                          = ip_configuration.value.name
      primary                       = ip_configuration.value.primary
      subnet_id                     = ip_configuration.value.subnet_id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
      public_ip_address_id          = ip_configuration.value.public_ip_address_id
    }
  }
}

resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  for_each = local.linux_virtual_machines

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name

  size           = local.linux_vm_image["size"]
  admin_username = var.vm_username
  admin_password = var.password

  disable_password_authentication = false

  network_interface_ids = each.value.network_interface_ids

  os_disk {
    name                 = each.value.os_disk_name
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = local.linux_vm_image["publisher"]
    offer     = local.linux_vm_image["offer"]
    sku       = local.linux_vm_image["sku"]
    version   = local.linux_vm_image["version"]
  }

  boot_diagnostics {
    storage_account_uri = ""
  }

  custom_data = each.value.custom_data
}

resource "azurerm_virtual_wan" "virtual_vwan" {
  for_each = local.virtual_wans

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name
}

resource "azurerm_virtual_hub" "virtual_hub" {
  for_each = local.virtual_hubs

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name           = each.value.name
  address_prefix = each.value.address_prefix
  virtual_wan_id = each.value.virtual_wan_id
}
