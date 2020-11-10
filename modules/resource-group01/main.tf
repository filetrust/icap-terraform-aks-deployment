
resource "azurerm_resource_group" "resource_group" {
  name     = var.service_name
  location = var.region

    tags = {
    created_by = "Mattp" 
  }
}
