
module "create_resource_group_UKSouth" {
	source						="./modules/resource-group01"
}

module "create_aks_cluster_UKSouth" {
	source						="./modules/aks01"
}

module "create_resource_group_NorthEurope" {
	source						="./modules/resource-group02"
}

module "create_aks_cluster_NorthEurope" {
	source						="./modules/aks02"
}