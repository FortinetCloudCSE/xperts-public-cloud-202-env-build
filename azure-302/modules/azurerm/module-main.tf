locals {

  user_common = {
    user_principal_domain = var.user_principal_domain
    display_name_ext      = var.username
    password              = var.password
    usage_location        = "US"
    account_enabled       = true
  }


  # VM Images and Sizes
  vm_images = {
    "spoke" = {
      size      = "Standard_D2s_v4"
      publisher = "Canonical"
      offer     = "ubuntu-24_04-lts"
      sku       = "server"
      version   = "latest"
    }

    # FortiManager VM Image and Size
    "fmg" = {
      publisher = "fortinet"
      offer     = "fortinet-fortimanager"
      sku       = "fortinet-fortimanager"
      size      = "Standard_D8s_v4"
      version   = "7.6.6"
    }

    # "faz" = {
    #   publisher = "fortinet"
    #   offer     = "fortinet-fortianalyzer"
    #   sku       = "fortinet-fortianalyzer"
    #   size      = "Standard_D8s_v4"
    #   version   = "7.6.6"
    # }

    "fgt" = {
      publisher = "fortinet"
      offer     = "fortinet_fortigate-vm"
      sku       = "fortinet_fg-vm_payg_76_g2"
      size      = "Standard_D4s_v4"
      version   = "7.6.6"
    }
  }

  public_ips = {
    # "pip-faz" = {
    #   resource_group_name = azurerm_resource_group.resource_group.name
    #   location            = azurerm_resource_group.resource_group.location

    #   name              = "pip-faz"
    #   allocation_method = "Static"
    #   sku               = "Standard"
    # }
    "pip-branch-fgt" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name              = "pip-branch-fgt"
      allocation_method = "Static"
      sku               = "Standard"
    }
    "pip-fmg" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name              = "pip-fmg"
      allocation_method = "Static"
      sku               = "Standard"
    }
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
    "Management_VNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name          = "Management_VNET"
      address_space = ["172.16.10.0/24"]
    }
    "Branch_VNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name          = "Branch_VNET"
      address_space = ["172.16.200.0/22"]
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
    "Management_SUBNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name                 = "Management_SUBNET"
      address_prefix       = ["172.16.10.0/24"]
      virtual_network_name = azurerm_virtual_network.virtual_network["Management_VNET"].name
    }
    "Branch_external_SUBNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name                 = "Branch_external_SUBNET"
      address_prefix       = ["172.16.200.0/24"]
      virtual_network_name = azurerm_virtual_network.virtual_network["Branch_VNET"].name
    }
    "Branch_internal_SUBNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name                 = "Branch_internal_SUBNET"
      address_prefix       = ["172.16.201.0/24"]
      virtual_network_name = azurerm_virtual_network.virtual_network["Branch_VNET"].name
    }
    "Branch_protected_SUBNET" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name                 = "Branch_protected_SUBNET"
      address_prefix       = ["172.16.202.0/24"]
      virtual_network_name = azurerm_virtual_network.virtual_network["Branch_VNET"].name
    }
  }

  network_interfaces = {
    "Linux-Spoke1-VM_nic" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "Linux-Spoke1-VM_nic"
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
    "Linux-Spoke2-VM_nic" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "Linux-Spoke2-VM_nic"
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
    "Linux-Branch-VM_nic" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "Linux-Branch-VM_nic"
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["Branch_protected_SUBNET"].id
          private_ip_address_allocation = "Dynamic"
          public_ip_address_id          = null
        }
      ]
    }
    "FortiManager-VM_nic" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "FortiManager-VM_nic"
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["Management_SUBNET"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = "172.16.10.4"
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-fmg"].id
        }
      ]
    }
    # "FortiAnalyzer-VM_nic" = {
    #   resource_group_name = azurerm_resource_group.resource_group.name
    #   location            = azurerm_resource_group.resource_group.location

    #   name = "FortiAnalyzer-VM_nic"
    #   ip_configurations = [
    #     {
    #       name                          = "ipconfig1"
    #       primary                       = true
    #       subnet_id                     = azurerm_subnet.subnet["Management_SUBNET"].id
    #       private_ip_address_allocation = "Static"
    #       private_ip_address            = "172.16.10.5"
    #       public_ip_address_id          = azurerm_public_ip.public_ip["pip-faz"].id
    #     }
    #   ]
    # }
    "FortiGate-VM_ext-nic" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "FortiGate-VM_ext-nic"
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["Branch_external_SUBNET"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = "172.16.200.4"
          public_ip_address_id          = azurerm_public_ip.public_ip["pip-branch-fgt"].id
        }
      ]
    }
    "FortiGate-VM_int-nic" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "FortiGate-VM_int-nic"
      ip_configurations = [
        {
          name                          = "ipconfig1"
          primary                       = true
          subnet_id                     = azurerm_subnet.subnet["Branch_internal_SUBNET"].id
          private_ip_address_allocation = "Static"
          private_ip_address            = "172.16.201.4"
          public_ip_address_id          = null
        }
      ]
    }
  }

  network_security_groups = {
    "nsg-utility" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "nsg-utility"
    }
  }

  network_security_rules = {
    "nsgsr-utility_ingress" = {
      resource_group_name = azurerm_resource_group.resource_group.name

      name                        = "nsgsr-utility_ingress"
      priority                    = 1001
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-utility"].name
    },
    "nsgsr-utility_egress" = {
      resource_group_name = azurerm_resource_group.resource_group.name

      name                        = "nsgsr-utility_egress"
      priority                    = 1002
      direction                   = "Outbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      network_security_group_name = azurerm_network_security_group.network_security_group["nsg-utility"].name
    }
  }

  subnet_network_security_group_associations = {
    "snet-management" = {
      subnet_id                 = azurerm_subnet.subnet["Management_SUBNET"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-utility"].id
    }
    "snet-branch" = {
      subnet_id                 = azurerm_subnet.subnet["Branch_external_SUBNET"].id
      network_security_group_id = azurerm_network_security_group.network_security_group["nsg-utility"].id
    }
  }

  linux_virtual_machines = {
    "Linux-Spoke1-VM" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "Linux-Spoke1-VM"
      network_interface_ids = [
        azurerm_network_interface.network_interface["Linux-Spoke1-VM_nic"].id,
      ]

      size = local.vm_images["spoke"].size

      source_image_reference_publisher = local.vm_images["spoke"].publisher
      source_image_reference_offer     = local.vm_images["spoke"].offer
      source_image_reference_sku       = local.vm_images["spoke"].sku
      source_image_reference_version   = local.vm_images["spoke"].version

      plan = []

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
        azurerm_network_interface.network_interface["Linux-Spoke2-VM_nic"].id,
      ]

      size = local.vm_images["spoke"].size

      source_image_reference_publisher = local.vm_images["spoke"].publisher
      source_image_reference_offer     = local.vm_images["spoke"].offer
      source_image_reference_sku       = local.vm_images["spoke"].sku
      source_image_reference_version   = local.vm_images["spoke"].version

      plan = []

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
    "Linux-Branch-VM" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "Linux-Branch-VM"
      network_interface_ids = [
        azurerm_network_interface.network_interface["Linux-Branch-VM_nic"].id,
      ]

      size = local.vm_images["spoke"].size

      source_image_reference_publisher = local.vm_images["spoke"].publisher
      source_image_reference_offer     = local.vm_images["spoke"].offer
      source_image_reference_sku       = local.vm_images["spoke"].sku
      source_image_reference_version   = local.vm_images["spoke"].version

      plan = []

      os_disk_name                 = "Linux-Branch-VM-OSDisk"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Standard_LRS"

      custom_data = base64encode(<<-EOF
        #cloud-config
        package_upgrade: true
        packages:
          - apache2
        runcmd:
          - sudo git clone https://github.com/movinalot/fortigate-demo-files.git
          - sudo cat fortigate-demo-files/index.html | sed "s/machine-name/Linux-Branch-VM/g" > index.html
          - sudo mv index.html fortigate-demo-files/index.html
          - sudo cp -r fortigate-demo-files/* /var/www/html/
        EOF
      )
    }
    # "vm-faz" = {
    #   resource_group_name = azurerm_resource_group.resource_group.name
    #   location            = azurerm_resource_group.resource_group.location

    #   name = "vm-faz"
    #   size = local.vm_images["faz"].size

    #   network_interface_ids = [azurerm_network_interface.network_interface["FortiAnalyzer-VM_nic"].id]

    #   identity_identity = "SystemAssigned"

    #   source_image_reference_publisher = local.vm_images["faz"].publisher
    #   source_image_reference_offer     = local.vm_images["faz"].offer
    #   source_image_reference_sku       = local.vm_images["faz"].sku
    #   source_image_reference_version   = local.vm_images["faz"].version

    #   plan = [{
    #     publisher = local.vm_images["faz"].publisher
    #     product   = local.vm_images["faz"].offer
    #     name      = local.vm_images["faz"].sku
    #   }]

    #   os_disk_name                 = "osdisk-faz"
    #   os_disk_caching              = "ReadWrite"
    #   os_disk_storage_account_type = "Premium_LRS"

    #   admin_username                  = var.vm_username
    #   admin_password                  = var.password
    #   disable_password_authentication = false
    #   custom_data = base64encode(templatefile("${path.module}/templates/faz-customdata.conf", {
    #     vm_name      = "vm-faz"
    #     license_flex = fortiflexvm_entitlements_vm_token.entitlements_vm_token["faz_vm"].token
    #   }))
    # }
    "vm-fmg" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "vm-fmg"
      size = local.vm_images["fmg"].size

      network_interface_ids = [azurerm_network_interface.network_interface["FortiManager-VM_nic"].id]

      identity_identity = "SystemAssigned"

      source_image_reference_publisher = local.vm_images["fmg"].publisher
      source_image_reference_offer     = local.vm_images["fmg"].offer
      source_image_reference_sku       = local.vm_images["fmg"].sku
      source_image_reference_version   = local.vm_images["fmg"].version

      plan = [{
        publisher = local.vm_images["fmg"].publisher
        product   = local.vm_images["fmg"].offer
        name      = local.vm_images["fmg"].sku
      }]

      os_disk_name                 = "osdisk-fmg"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"

      disable_password_authentication = false
      custom_data = base64encode(templatefile("${path.module}/templates/fmg-customdata.conf", {
        vm_name      = "vm-fmg"
        port1_ip     = "172.16.10.4"
        port1_mask   = "255.255.255.0"
        port1_gw     = "172.16.10.1"
        license_flex = fortiflexvm_entitlements_vm_token.entitlements_vm_token["fmg_vm"].token
      }))
    }
    "vm-branch-fgt" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name                  = "vm-branch-fgt"
      network_interface_ids = [for nic in ["FortiGate-VM_ext-nic", "FortiGate-VM_int-nic"] : azurerm_network_interface.network_interface[nic].id]

      size = local.vm_images["fgt"].size

      source_image_reference_publisher = local.vm_images["fgt"].publisher
      source_image_reference_offer     = local.vm_images["fgt"].offer
      source_image_reference_sku       = local.vm_images["fgt"].sku
      source_image_reference_version   = local.vm_images["fgt"].version

      plan = [{
        publisher = local.vm_images["fgt"].publisher
        product   = local.vm_images["fgt"].offer
        name      = local.vm_images["fgt"].sku
      }]

      os_disk_name                 = "osdisk-fgt"
      os_disk_caching              = "ReadWrite"
      os_disk_storage_account_type = "Premium_LRS"

      custom_data = base64encode(templatefile("${path.module}/templates/fgt-customdata.conf", {
          fgt_vm_name           = "vm-branch-fgt"
          fgt_license_file      = ""
          fgt_license_fortiflex = ""
          fgt_username          = ""
          fgt_ssh_public_key    = ""
          vnet_network          = "172.16.200.0/22"
          fgt_external_ipaddr   = "172.16.200.4"
          fgt_external_mask     = "255.255.255.0"
          fgt_external_gw       = "172.16.200.1"
          fgt_internal_ipaddr   = "172.16.201.4"
          fgt_internal_mask     = "255.255.255.0"
          fgt_internal_gw       = "172.16.201.1"
        }
      ))
    }
  }

  route_tables = {
    "rt-protected" = {
      resource_group_name = azurerm_resource_group.resource_group.name
      location            = azurerm_resource_group.resource_group.location

      name = "rt-protected"
    }
  }

  routes = {
    "udr-default" = {
      resource_group_name = azurerm_resource_group.resource_group.name

      name                   = "udr-default"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = azurerm_network_interface.network_interface["FortiGate-VM_int-nic"].private_ip_address
      next_hop_type          = "VirtualAppliance"
      route_table_name       = azurerm_route_table.route_table["rt-protected"].name
    }
  }

  subnet_route_table_associations = {
    "snet-protected" = {
      subnet_id      = azurerm_subnet.subnet["Branch_protected_SUBNET"].id
      route_table_id = azurerm_route_table.route_table["rt-protected"].id
    }
  }
}

resource "azurerm_managed_disk" "managed_disk" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  name = "datadisk-fgt"

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 50
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  managed_disk_id    = azurerm_managed_disk.managed_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.linux_virtual_machine["vm-branch-fgt"].id
  lun                = 0
  caching            = "ReadWrite"
}

data "fortiflexvm_entitlements_list" "entitlements_list" {
  for_each = var.fortiflex_serial_numbers

  config_id     = var.fortiflexvm_config_ids[each.key]
  serial_number = each.value.fortiflex_serial
}

resource "fortiflexvm_entitlements_vm" "entitlements_vm" {
  for_each = var.fortiflex_serial_numbers

  config_id     = var.fortiflexvm_config_ids[each.key]
  serial_number = each.value.fortiflex_serial
  status        = data.fortiflexvm_entitlements_list.entitlements_list[each.key].entitlements[0].status != "ACTIVE" ? "ACTIVE" : data.fortiflexvm_entitlements_list.entitlements_list[each.key].entitlements[0].status

  lifecycle {
    ignore_changes = [status]
  }
}

resource "fortiflexvm_entitlements_vm_token" "entitlements_vm_token" {
  for_each = var.fortiflex_serial_numbers

  config_id        = var.fortiflexvm_config_ids[each.key]
  serial_number    = each.value.fortiflex_serial
  regenerate_token = data.fortiflexvm_entitlements_list.entitlements_list[each.key].token_status == "USED" && data.fortiflexvm_entitlements_list.entitlements_list[each.key].entitlements[0].status == "ACTIVE" ? false : true

  lifecycle {
    ignore_changes = [regenerate_token]
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

  group_object_id  = var.public_cloud_group_object_id
  member_object_id = azuread_user.user.object_id
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.username}-${var.rg_suffix}"
  location = var.location

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_public_ip" "public_ip" {
  for_each = local.public_ips

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name              = each.value.name
  allocation_method = each.value.allocation_method
  sku               = each.value.sku
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
      private_ip_address            = lookup(ip_configuration.value, "private_ip_address", null)
      public_ip_address_id          = ip_configuration.value.public_ip_address_id
    }
  }
}

resource "azurerm_network_security_group" "network_security_group" {
  for_each = local.network_security_groups

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name
}

resource "azurerm_network_security_rule" "network_security_rule" {
  for_each = local.network_security_rules

  resource_group_name = each.value.resource_group_name

  name = each.value.name

  network_security_group_name = each.value.network_security_group_name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
}

resource "azurerm_subnet_network_security_group_association" "subnet_network_security_group_association" {
  for_each = local.subnet_network_security_group_associations

  subnet_id                 = each.value.subnet_id
  network_security_group_id = each.value.network_security_group_id
}

resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  for_each = local.linux_virtual_machines

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name                  = each.value.name
  network_interface_ids = each.value.network_interface_ids

  size = each.value.size

  admin_username = var.vm_username
  admin_password = var.password

  disable_password_authentication = false

  source_image_reference {
    publisher = each.value.source_image_reference_publisher
    offer     = each.value.source_image_reference_offer
    sku       = each.value.source_image_reference_sku
    version   = each.value.source_image_reference_version
  }

  dynamic "plan" {
    for_each = each.value.plan
    content {
      publisher = plan.value.publisher
      product   = plan.value.product
      name      = plan.value.name
    }
  }

  os_disk {
    name                 = each.value.os_disk_name
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.os_disk_storage_account_type
  }

  custom_data = each.value.custom_data

  boot_diagnostics {
    storage_account_uri = ""
  }
}

resource "azurerm_route_table" "route_table" {
  for_each = local.route_tables

  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  name = each.value.name
}

resource "azurerm_route" "route" {
  for_each = local.routes

  resource_group_name = each.value.resource_group_name

  name                   = each.value.name
  route_table_name       = each.value.route_table_name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "subnet_route_table_association" {
  for_each = local.subnet_route_table_associations

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
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

output "public_ips" {
  value = azurerm_public_ip.public_ip[*]
}

output "fad_vm_tokens" {
  value = {
    value = fortiflexvm_entitlements_vm_token.entitlements_vm_token[*]
  }
}