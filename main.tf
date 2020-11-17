
module "create_resource_group_UKSouth" {
	source						="./modules/resource-group01"
}

module "create_aks_cluster_UKSouth" {
	source						="./modules/aks01"
}
