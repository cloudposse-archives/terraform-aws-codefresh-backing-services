# mq variables
#--------------------------------------------------------------
variable "mq_apply_immediately" {
  type        = "string"
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  default     = "true"
}

variable "mq_enabled" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

variable "mq_auto_minor_version_upgrade" {
  type        = "string"
  description = "Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions"
  default     = "false"
}

variable "mq_broker_name" {
  type        = "string"
  description = "The name of the broker"
  default     = "mq"
}

variable "mq_deployment_mode" {
  type        = "string"
  description = "The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ"
  default     = "ACTIVE_STANDBY_MULTI_AZ"
}

variable "mq_engine_type" {
  type        = "string"
  description = "The type of broker engine. Currently, Amazon MQ supports only ActiveMQ"
  default     = "ActiveMQ"
}

variable "mq_engine_version" {
  type        = "string"
  description = "The version of the broker engine. Currently, Amazon MQ supports only 5.15.0 or 5.15.6."
  default     = "5.15.0"
}

variable "mq_configuration_name" {
  type        = "string"
  description = "The name of the MQ configuration"
  default     = "mq"
}

variable "mq_host_instance_type" {
  type        = "string"
  description = "The broker's instance type. e.g. mq.t2.micro or mq.m4.large"
  default     = "mq.t2.micro"
}

variable "mq_publicly_accessible" {
  type        = "string"
  description = "Whether to enable connections from applications outside of the VPC that hosts the broker's subnets."
  default     = "false"
}

variable "mq_general_log" {
  type        = "string"
  description = "Enables general logging via CloudWatch"
  default     = "true"
}

variable "mq_audit_log" {
  type        = "string"
  description = "Enables audit logging. User management action made using JMX or the ActiveMQ Web Console is logged"
  default     = "true"
}

variable "mq_maintenance_day_of_week" {
  type        = "string"
  description = "The day of the week. e.g. MONDAY, TUESDAY, or WEDNESDAY"
  default     = "SUNDAY"
}

variable "mq_maintenance_time_of_day" {
  type        = "string"
  description = "The time, in 24-hour format. e.g. 02:00"
  default     = "03:00"
}

variable "mq_maintenance_time_zone" {
  type        = "string"
  description = "The time zone, in either the Country/City format, or the UTC offset format. e.g. CET"
  default     = "UTC"
}

variable "mq_admin_user" {
  type        = "string"
  description = "Admin username"
  default     = ""
}

variable "mq_admin_password" {
  type        = "string"
  description = "Admin password"
  default     = ""
}

variable "mq_config_template_path" {
  type        = "string"
  description = "Path to ActiveMQ XML config"
  default     = ""
}

# mq data
#--------------------------------------------------------------
data "template_file" "default" {
  count    = "${local.mq_enabled ? 1 : 0}"
  template = "${file(local.mq_config_template_path)}"
}

# mq locals
#--------------------------------------------------------------
locals {
  mq_enabled              = "${var.mq_enabled == "true" ? true : false}"
  mq_admin_user           = "${length(var.mq_admin_user) > 0 ? var.mq_admin_user : join("", random_string.mq_admin_user.*.result)}"
  mq_admin_password       = "${length(var.mq_admin_password) > 0 ? var.mq_admin_password : join("", random_string.mq_admin_password.*.result)}"
  mq_config_template_path = "${length(var.mq_config_template_path) > 0 ? var.mq_config_template_path : format("%s/templates/mq_default_config.xml", path.module)}"
}

# mq resources
#--------------------------------------------------------------
resource "random_string" "mq_admin_user" {
  count   = "${local.mq_enabled ? 1 : 0}"
  length  = 8
  special = false
  number  = false
}

resource "random_string" "mq_admin_password" {
  count   = "${local.mq_enabled ? 1 : 0}"
  length  = 16
  special = true
}

resource "aws_mq_configuration" "default" {
  count          = "${local.mq_enabled ? 1 : 0}"
  name           = "${var.mq_configuration_name}"
  engine_type    = "${var.mq_engine_type}"
  engine_version = "${var.mq_engine_version}"
  data           = "${data.template_file.default.rendered}"
}

resource "aws_mq_broker" "default" {
  count       = "${local.mq_enabled ? 1 : 0}"
  broker_name = "${var.mq_broker_name}"

  configuration {
    id       = "${join("", aws_mq_configuration.default.*.id)}"
    revision = "${join("", aws_mq_configuration.default.*.latest_revision)}"
  }

  deployment_mode            = "${var.mq_deployment_mode}"
  engine_type                = "${var.mq_engine_type}"
  engine_version             = "${var.mq_engine_version}"
  host_instance_type         = "${var.mq_host_instance_type}"
  auto_minor_version_upgrade = "${var.mq_auto_minor_version_upgrade}"
  apply_immediately          = "${var.mq_apply_immediately}"
  publicly_accessible        = "${var.mq_publicly_accessible}"
  security_groups            = ["${module.kops_metadata.nodes_security_group_id}"]
  subnet_ids                 = ["${module.subnets.private_subnet_ids}"]

  logs {
    general = "${var.mq_general_log}"
    audit   = "${var.mq_audit_log}"
  }

  maintenance_window_start_time {
    day_of_week = "${var.mq_maintenance_day_of_week}"
    time_of_day = "${var.mq_maintenance_time_of_day}"
    time_zone   = "${var.mq_maintenance_time_zone}"
  }

  user {
    username       = "${local.mq_admin_user}"
    password       = "${local.mq_admin_password}"
    console_access = true
    groups         = ["admin"]
  }
}

resource "aws_ssm_parameter" "mq_master_username" {
  count       = "${local.mq_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "mq_admin_username")}"
  value       = "${local.mq_admin_user}"
  description = "MQ Username for the master user"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "mq_master_password" {
  count       = "${local.mq_enabled ? 1 : 0}"
  name        = "${format(var.chamber_parameter_name, local.chamber_service, "mq_admin_password")}"
  value       = "${local.mq_admin_password}"
  description = "MQ Password for the master user"
  type        = "SecureString"
  key_id      = "${data.aws_kms_key.chamber_kms_key.id}"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

# mq modules
#--------------------------------------------------------------
module "dns_master" {
  source    = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.2.5"
  namespace = "${var.namespace}"
  name      = "active.${var.mq_broker_name}"
  stage     = "${var.stage}"
  zone_id   = "${local.zone_id}"
  records   = ["${coalescelist(aws_mq_broker.default.*.instances.0.endpoints.0, list(""))}"]
  enabled   = "${local.mq_enabled && length(local.zone_id) > 0 ? "true" : "false"}"
}

# mq outputs
#--------------------------------------------------------------
output "mq_broker_id" {
  value = "${join("", aws_mq_broker.default.*.id)}"
}

output "mq_broker_arn" {
  value = "${join("", aws_mq_broker.default.*.arn)}"
}

output "mq_broker_instances" {
  value = "${join("", aws_mq_broker.default.*.instances)}"
}
