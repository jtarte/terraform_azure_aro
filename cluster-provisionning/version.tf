###############################################################################
# Terraform init values
#
# author: Jérôme TARTE
# team: IBM Cloud Expert Labs, SWAT team
# email: jerome.tarte@fr.ibm.com
###############################################################################

# used version of terraform
terraform {
  required_version = ">= 1.0.8"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.46"
    }
  }
}