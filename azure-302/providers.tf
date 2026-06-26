provider "azuread" {
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "fortiflexvm" {
  # FortiFLEX VM provider configuration username and password are pulled from environment variables
  username = var.fortiflex_access_username
  password = var.fortiflex_access_password
}