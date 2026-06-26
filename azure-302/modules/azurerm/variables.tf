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

variable "public_cloud_group_object_id" {
  type    = string
  default = ""
}

variable "fortiflexvm_config_ids" {
  description = "FortiFlexVM Config IDs"
  type        = map(string)
  default     = {}
}

variable "fortiflex_serial_numbers" {
  description = "Map of FAZ and FMG FortiFlexVM serial numbers"
  type        = map(any)
}

variable "fortiflex_access_username" {
  description = "FortiFlexVM Access Username"
  type        = string
  default     = ""
}

variable "fortiflex_access_password" {
  description = "FortiFlexVM Access Password"
  type        = string
  default     = ""
}