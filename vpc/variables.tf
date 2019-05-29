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
variable "public_subnets" {
  type = "list"
  default = []
}
variable "private_subnets" {
  type = "list"
  default = []
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
