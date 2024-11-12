# set the Azure Provider source and version being used
provider "azurerm" {
  features {}
  # # IG Enterprise Dev/Test:
  # subscription_id = "b07e774d-79b6-4138-8283-96a8e860f46f"

  # Juan Sandbox in IGLab.net
  subscription_id = "60c86bb6-cbb2-4afe-9e66-76df669d0e00"

  # # Sandbox in IGLab.net
  # subscription_id = "8b23d5df-10c6-4fec-9eb1-b472ba22988a"

}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}