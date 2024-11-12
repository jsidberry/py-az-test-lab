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
variable "subscription_id" {}
variable "admin_username" {}
variable "admin_password" {}
