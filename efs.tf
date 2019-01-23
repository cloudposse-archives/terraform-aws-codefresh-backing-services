variable "efs_enabled" {
  type        = "string"
  default     = ""
  description = "Set to false to prevent the module from creating any resources"
}

variable "efs_subnet_ids" {
  type        = "list"
  default     = []
  description = "A list of subnet IDs for EFS"
}

variable "efs_vpc_id" {
  type        = "string"
  default     = ""
  description = "VPC ID for EFS"
}

locals {
  efs_enabled    = "${var.efs_enabled != "" ? var.efs_enabled : var.enabled}"
  efs_subnet_ids = "${length(var.efs_subnet_ids) > 0 ? var.efs_subnet_ids : var.subnets }"
  efs_vpc_id     = "${var.efs_vpc_id != "" ? var.efs_vpc_id ? : var.vpc_id }"
}

module "efs" {
  source             = "git::https://github.com/cloudposse/terraform-aws-efs.git?ref=add_enabled_flag"
  enabled            = "${local.efs_enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  aws_region         = "${data.aws_region.current.name}"
  vpc_id             = "${local.efs_vpc_id}"
  subnets            = "${local.efs_subnet_ids}"
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  security_groups    = ["${var.security_groups}"]
  zone_id            = "${local.zone_id}"
}

output "efs_arn" {
  value       = "${local.efs_enabled == "true" ? module.efs.arn : ""}"
  description = "EFS arn"
}

output "efs_id" {
  value       = "${local.efs_enabled == "true" ? module.efs.id : ""}"
  description = "EFS ID"
}

output "efs_host" {
  value       = "${local.efs_enabled == "true" ? module.efs.host : ""}"
  description = "EFS host"
}

output "efs_dns_name" {
  value       = "${local.efs_enabled == "true" ? module.efs.dns_name : ""}"
  description = "EFS DNS name"
}

output "efs_mount_target_dns_names" {
  value       = "${local.efs_enabled == "true" ? module.efs.mount_target_dns_names : ""}"
  description = "EFS mount target DNS names"
}

output "efs_mount_target_ids" {
  value       = "${local.efs_enabled == "true" ? module.efs.mount_target_ids : ""}"
  description = "EFS mount target IDs"
}

output "efs_mount_target_ips" {
  value       = "${local.efs_enabled == "true" ? module.efs.mount_target_ips : ""}"
  description = "EFS mount target IPs"
}

output "efs_network_interface_ids" {
  value       = "${local.efs_enabled == "true" ? module.efs.network_interface_ids : ""}"
  description = "EFS network interface IDs"
}
