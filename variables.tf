
variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "location" {
  type = string
}

# Addressing for subnets
variable "vnet_cidr" {
  type = string # e.g., "10.0.0.0/16"
}

variable "subnet_mgmt" {
  type = string # e.g., "10.0.1.0/24"
}

variable "subnet_web" {
  type = string # e.g., "10.0.2.0/24"
}

variable "subnet_app" {
  type = string # e.g., "10.0.3.0/24"
}

variable "subnet_backend" {
  type = string # e.g., "10.0.4.0/24"
}

# SSH source for management access (e.g., "203.0.113.42/32" or a CIDR)
variable "admin_allowed_cidr" {
  type = string
}

# Availability set
variable "availability_set_name" {
  type = string
}

variable "platform_fault_domain_count" {
  type    = number
  default = 2
}

variable "platform_update_domain_count" {
  type    = number
  default = 5
}

# VM settings
variable "admin_username" {
  type = string
}

# Path to an SSH public key file (e.g., "~/.ssh/id_rsa.pub")
variable "ssh_public_key" {
  type    = string
  default = null
}

# Optional: allow changing VM size via tfvars
variable "mgmt_vm_size" {
  type    = string
  default = "Standard_B2s"
}

# Web VM settings
variable "web_vm_size" {
  type    = string
  default = "Standard_B2s"
}

# Path to the cloud-init file used to install Apache on web VMs

variable "cloud_init_web_path" {
  description = "Optional override for the web VM cloud-init YAML path."
  type        = string
  default     = null
}



# Number of web VMs (keep 2 for the challenge)
variable "web_vm_count" {
  type    = number
  default = 2
}

# Optional names and tuning
variable "lb_name" {
  type    = string
  default = "web-lb"
}

variable "lb_pip_name" {
  type    = string
  default = "web-lb-pip"
}

# Optional: customize frontend name
variable "lb_frontend_name" {
  type    = string
  default = "public-fe"
}

# Optional: probe and rule ports (keep defaults for HTTP)
variable "lb_http_frontend_port" {
  type    = number
  default = 80
}

variable "lb_http_backend_port" {
  type    = number
  default = 80
}

# Storage Account name must be globally unique, 3–24 lowercase alphanum.
variable "storage_account_name" {
  type = string
}

# Optional containers list (defaults to the two required by the challenge)
variable "storage_containers" {
  type    = list(string)
  default = ["terraformstate", "weblogs"]
}

# Choose replication; challenge wants GRS
variable "storage_replication_type" {
  type    = string
  default = "GRS" # Valid: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
}

#locals


locals {
  cloud_init_web_path = coalesce(
    var.cloud_init_web_path,
    "${path.module}/cloud-init-web.yaml"
  )
}

