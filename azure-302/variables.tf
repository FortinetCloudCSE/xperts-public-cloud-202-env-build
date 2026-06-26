variable "username_prefix" {
  description = "Prefix for the username"
  type        = string
  default     = ""
}

variable "vm_username" {
  description = "Username for the virtual machine"
  type        = string
  default     = ""
}
variable "user_count" {
  description = "Number of users to create"
  type        = string
  default     = "0"
}
variable "user_start" {
  description = "Starting index for user numbering"
  type        = string
  default     = "0"
}

variable "rg_suffix" {
  description = "Suffix for the resource group name"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = ""
}

variable "password" {
  description = "Password for the admin user"
  type        = string
  default     = ""
}

variable "fortiflexvm_config_ids" {
  description = "FortiFlexVM Config IDs"
  type        = map(string)
  default     = {}
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

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "user_principal_domain" {
  description = "The domain name for the Azure AD tenant"
  type        = string
  default     = ""
}

variable "public_cloud_group_object_id" {
  description = "The ID of the Entra ID group to add users to"
  type        = string
  default     = ""
}

variable "fortiflex_serial_numbers" {
  description = "Map of FAZ and FMG FortiFlexVM serial numbers"
  type        = map(any)
  default     = {}
}
