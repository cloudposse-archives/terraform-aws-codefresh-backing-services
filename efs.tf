variable "efs_enabled" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

module "efs" {
  source             = "git::https://github.com/cloudposse/terraform-aws-efs.git?ref=tags/0.8.1"
  enabled            = "${var.efs_enabled == "true" && var.enabled == "true"}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  attributes         = ["efs"]
  aws_region         = "${data.aws_region.current.name}"
  vpc_id             = "${var.vpc_id}"
  subnets            = "${var.subnet_ids}"
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  security_groups    = ["${var.security_groups}"]
  zone_id            = "${local.zone_id}"
}

output "efs_arn" {
  value       = "${module.efs.arn}"
  description = "EFS arn"
}

output "efs_id" {
  value       = "${module.efs.id}"
  description = "EFS ID"
}

output "efs_host" {
  value       = "${module.efs.host}"
  description = "EFS host"
}

output "efs_dns_name" {
  value       = "${module.efs.dns_name}"
  description = "EFS DNS name"
}

output "efs_mount_target_dns_names" {
  value       = "${module.efs.mount_target_dns_names}"
  description = "EFS mount target DNS names"
}

output "efs_mount_target_ids" {
  value       = "${module.efs.mount_target_ids}"
  description = "EFS mount target IDs"
}

output "efs_mount_target_ips" {
  value       = "${module.efs.mount_target_ips}"
  description = "EFS mount target IPs"
}

output "efs_network_interface_ids" {
  value       = "${module.efs.network_interface_ids}"
  description = "EFS network interface IDs"
}
