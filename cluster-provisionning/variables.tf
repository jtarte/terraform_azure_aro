###############################################################################
# Terraform variable definition
#
# author: Jérôme TARTE
# team: IBM Cloud Expert Labs, SWAT team
# email: jerome.tarte@fr.ibm.com
###############################################################################

# Azure subscription id
variable "subscription_id" {
  description = "Subscription id of Azure account"
}

# Azure subscription tenant id
variable "subscription_tenant_id" {
  description = "Subscription tenant id of Azure account"
}

# Azure region
variable "region"{
    description = "Azure region used for deployment"
    default = "canadacentral"
}

variable "resource_group"{
  description = "resource group used for the deployment of the ARO cluster"
}

variable "cluster_name"{
  description = " name of the cluster"
}


variable "vnet"{
  description = "name of vnet used to deploy ARO cluster"
}
variable "master_subnet"{
  description = "name of subnet for master nodes"
}
variable "worker_subnet"{
  description = "name of subnet for master nodes"
}

variable "worker_count"{
  description = "number of worker nodes in the cluster"
  default = 3
}

variable "worker_flavor"{
  description = " flavor of the vm used for worker nodes"
  default = "Standard_D8s_v3"
}

variable "master_flavor"{
  description = " flavor of the vm used for master nodes"
  default = "Standard_D8s_v3"
}

variable "apiserver-visibility"{
  description = "define what is the visibility of aro cluster api"
  default = "Public"
}

variable "ingress-visibility"{
  description = "define what is the visibility of aro ingress"
  default = "Public"
}