# efs modules 
#--------------------------------------------------------------
module "efs" {
  source             = "git::https://github.com/cloudposse/terraform-aws-efs.git?ref=tags/0.7.1"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  aws_region         = "${data.aws_region.current.name}"
  vpc_id             = "${var.vpc_id}"
  subnets            = "${var.subnet_ids}"
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  security_groups    = ["${var.node_security_groups}"]
  zone_id            = "${local.zone_id}"
}

# efs outputs
#--------------------------------------------------------------
output "efs_arn" {
  value = "${module.efs.arn}"
}

output "efs_id" {
  value = "${module.efs.id}"
}

output "efs_host" {
  value = "${module.efs.host}"
}

output "efs_dns_name" {
  value = "${module.efs.dns_name}"
}

output "efs_mount_target_dns_names" {
  value = "${module.efs.mount_target_dns_names}"
}

output "efs_mount_target_ids" {
  value = "${module.efs.mount_target_ids}"
}

output "efs_mount_target_ips" {
  value = "${module.efs.mount_target_ips}"
}

output "efs_network_interface_ids" {
  value = "${module.efs.network_interface_ids}"
}
