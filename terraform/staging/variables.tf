variable "location" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "app_service_plan_name" {
  type = string
}

variable "webapp_name" {
  type = string
}
