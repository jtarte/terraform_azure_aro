###############################################################################
# Terraform main module
#
# author: Jérôme TARTE
# team: IBM Cloud Expert Labs, SWAT team
# email: jerome.tarte@fr.ibm.com
###############################################################################

data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

data "azurerm_virtual_network" "vnet"{
  name = var.vnet
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "master_subnet" {
  name                 = var.master_subnet
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "worker_subnet" {
  name                 = var.worker_subnet
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

resource "null_resource" "aro_cluster" {
  triggers = {
    rg = data.azurerm_resource_group.rg.name
    cluster = var.cluster_name
  }
  
  provisioner "local-exec" {
      command = "az aro create --name ${var.cluster_name} --resource-group ${data.azurerm_resource_group.rg.name} --vnet ${data.azurerm_virtual_network.vnet.name} --master-subnet ${data.azurerm_subnet.master_subnet.name} --worker-subnet ${data.azurerm_subnet.worker_subnet.name} --apiserver-visibility ${var.apiserver-visibility} --ingress-visibility ${var.ingress-visibility} --master-vm-size ${var.master_flavor} --worker-vm-size ${var.worker_flavor} --worker-count ${var.worker_count} --pull-secret @pull-secret.txt"
  }
  provisioner "local-exec" {
      when = destroy
      command = "az aro delete -g ${self.triggers.rg} -n ${self.triggers.cluster} -y"
  }
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [null_resource.aro_cluster]

  create_duration = "60s"
}

resource "null_resource" "console" {
  provisioner "local-exec" {
    command  = "az aro show --name ${var.cluster_name} --resource-group ${data.azurerm_resource_group.rg.name} --query \"consoleProfile.url\" -o tsv | tr -d '\n' > console.txt"
  }
  depends_on = [time_sleep.wait_60_seconds]
}

data "local_file"  "console" {
  filename  = "${path.module}/console.txt"
  depends_on = [null_resource.console]
}

resource "null_resource" "pwd" {
  provisioner "local-exec" {
    command  = "az aro list-credentials --name ${var.cluster_name} --resource-group ${data.azurerm_resource_group.rg.name} --query \"kubeadminPassword\" -o tsv | tr -d '\n' > pwd.txt"
  }
  depends_on = [time_sleep.wait_60_seconds]
}

data "local_file"  "pwd" {
  filename  = "${path.module}/pwd.txt"
  depends_on = [null_resource.pwd]
}

resource "null_resource" "apiserver" {
  provisioner "local-exec" {
    command  = "az aro show --name ${var.cluster_name} --resource-group ${data.azurerm_resource_group.rg.name} --query \"apiserverProfile.url\" -o tsv | tr -d '\n' > api.txt"
  }
  depends_on = [time_sleep.wait_60_seconds]
}
data "local_file"  "api" {
  filename  = "${path.module}/api.txt"
  depends_on = [null_resource.apiserver]
}

resource "null_resource" "oc-login" {
  provisioner "local-exec" {
   command  = "oc login -u kubeadmin -p ${data.local_file.pwd.content} ${data.local_file.api.content} --insecure-skip-tls-verify"  
  }
  depends_on = [data.local_file.api, data.local_file.pwd,time_sleep.wait_60_seconds]
}


resource "null_resource" "gitops" {
  provisioner "local-exec" {
   command  = "./deploy-gitops.sh"
    working_dir = "../gitops"
  }
  depends_on = [resource.null_resource.oc-login]
}

resource "null_resource" "file-sc" {
  provisioner "local-exec" {
   command  = "./deploy-file-sc.sh ${var.cluster_name} ${data.azurerm_resource_group.rg.name}"
    working_dir = "../azure-file"
  }
  depends_on = [resource.null_resource.oc-login]
}


data "template_file" "result" {
  template = "${file("${path.module}/result.tpl")}"
  vars = {
    cluster_name = "${var.cluster_name}",
    password = "${data.local_file.pwd.content}",
    console_url = "${data.local_file.console.content}"
    api_server= "${data.local_file.api.content}"
  }
  depends_on = [data.local_file.pwd, data.local_file.console, resource.null_resource.file-sc, resource.null_resource.gitops]
}

output "rendered" {
  value = "${data.template_file.result.rendered}"
}