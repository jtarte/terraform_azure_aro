###############################################################################
# Terraform init values
#
# author: Jérôme TARTE
# team: IBM Cloud Expert Labs, SWAT team
# email: jerome.tarte@fr.ibm.com
###############################################################################

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.subscription_tenant_id
}