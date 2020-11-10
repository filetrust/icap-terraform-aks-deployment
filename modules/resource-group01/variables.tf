variable "service_name" {
  description = "This is a consolidated name based on org, environment, region"
  type        = string
  default     = "gw-icap-aks-deploy-UKS"
}

variable "region" {
  description = "The Azure Region"
  type        = string
  default     = "UKSouth"
}
