variable "tier" {
  description = "The tiers for the resource groups"
  type        = list(string)
  default     = ["lab"]
}
variable "region" { default = "eus2" }
variable "loc" { default = "eastus2" }
variable "app" { default = "k8s" }
variable "provisionedby" {}
variable "supportcontact" {}
# variable "image_url" {
#   default = "/subscriptions/8b23d5df-10c6-4fec-9eb1-b472ba22988a/resourceGroups/SandboxGalleryRG/providers/Microsoft.Compute/galleries/SandboxGallery/images/sandbox-rhl9-baseimage"
# }

# variable "subnet_id" {
#   default = "/subscriptions/8b23d5df-10c6-4fec-9eb1-b472ba22988a/resourceGroups/ProdOps-RG/providers/Microsoft.Network/virtualNetworks/rhel8testbox-vnet/subnets/rhel8testbox_subnet"
# }
variable "subscription_id" {}

# variable "target_rg" {}
# variable "target_nsg" {}
# variable "gallery_rg" {}
# variable "gallery_name" {}
# variable "vm_image" {}
# variable "target_vnet" {}
# variable "target_subnet" {}
variable "admin_username" {}
variable "admin_password" {}
