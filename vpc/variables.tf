variable "name" {
    type = "string"
  default = ""
}
variable "cidr_block" {
    type = "string"
  default = ""
}
variable "instance_tenancy" {
    type = "string"
  default = ""
}
variable "public_cidr_block" {
  type = "list"
  default = ["",""]
}
variable "private_cidr_block" {
  type = "list"
  default = ["",""]
}
variable "azs" {
  type = "list"
  default = []
}
variable "enable_dns_hostname" {
  type = "string"
  default = true
}
variable "enable_dns_support" {
  type = "string"
  default = true
}
variable "map_public_ip_on_launch" {
  default = true
}
variable "enable_s3_endpoint" {
  default     = false
}

variable "enable_dynamodb_endpoint" {
  default     = false
}
variable "security_group_name" {
  description = ""
  default     = "eks"
}
variable "security_group_description" {
  default = "Security Group managed by Terraform"
}
variable "inbound_rules_cluster" {
  type = "map"

  default = {
    "0" = ["0.0.0.0/0", "80", "80", "TCP"]
    "1" = ["0.0.0.0/0", "443", "443", "TCP"]
  }
}
variable "inbound_rules_nodes" {
  type = "map"

  default = {
    "0" = ["0.0.0.0/0", "80", "80", "TCP"]
    "1" = ["0.0.0.0/0", "443", "443", "TCP"]
  }
}
variable "outbound_rules" {
  type = "map"

  default = {
    "0" = ["0.0.0.0/0", "0", "0", "-1"]
  }
}
