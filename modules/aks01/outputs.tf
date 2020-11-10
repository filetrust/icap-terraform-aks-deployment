output "cluster_name" {
	value = "${azurerm_kubernetes_cluster.icap-deploy.name}"
}

output "cluster_dns" {
	value = "${azurerm_kubernetes_cluster.icap-deploy.dns_prefix}"
}

output "secret_value_1" {
  value = data.azurerm_key_vault_secret.spusername.value
}

output "secret_value_2" {
  value = data.azurerm_key_vault_secret.sppassword.value
}
