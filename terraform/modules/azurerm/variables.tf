variable "vm_username" {
  description = "Username for the VM user"
  type        = string
}

variable "username" {
  description = "Username for the VM user"
  type        = string
}

variable "password" {
  description = "Password for the VM user"
  type        = string
}

variable "rg_suffix" {
  description = "The suffix to use for all resource group names"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
}

variable "user_principal_domain" {
  description = "The domain name for the Entra ID tenant"
  type        = string
  default     = ""
}

variable "public_cloud_202_group_object_id" {
  type    = string
  default = ""
}