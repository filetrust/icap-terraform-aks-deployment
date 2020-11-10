data "azurerm_key_vault" "keyvault" {
  name                = "${var.keyvault_name}"
  resource_group_name = "${var.vault_resourcegroup_name}"
}

data "azurerm_key_vault_secret" "spusername" {
  name         = "${var.secret_sp_1}"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

data "azurerm_key_vault_secret" "sppassword" {
  name         = "${var.secret_sp_2}"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

resource "azurerm_kubernetes_cluster" "icap-deploy" {
  name                = "${var.prefix}-aks"
  location            = var.region
  resource_group_name = var.resource_group 
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name            = "icaptestnode"
    node_count      = 1
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 10
  }

  service_principal {
    client_id     = data.azurerm_key_vault_secret.spusername.value
    client_secret = data.azurerm_key_vault_secret.sppassword.value
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    created_by = "Mattp" 
  }
}
