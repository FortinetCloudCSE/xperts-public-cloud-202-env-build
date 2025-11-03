locals {

  username_prefix = var.username_prefix
  user_count      = tonumber(var.user_count)
  user_start      = tonumber(var.user_start)

  rg_suffix             = var.rg_suffix
  location              = var.location
  password              = var.password
  user_principal_domain = var.user_principal_domain

  environments = {
    for i in range(local.user_start, local.user_start + local.user_count) :
    format("%s%02s", local.username_prefix, i) => { username = format("%s%02s", local.username_prefix, i) }
  }
}

module "module_public-cloud-202" {
  for_each = local.environments

  source = "./modules/azurerm"

  location                         = local.location
  rg_suffix                        = local.rg_suffix
  username                         = each.value.username
  vm_username                      = var.vm_username
  password                         = local.password
  user_principal_domain            = local.user_principal_domain
  public_cloud_202_group_object_id = var.public_cloud_202_group_object_id
}
