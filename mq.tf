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

variable "mq_subnet_ids" {
  type        = "list"
  default     = []
  description = "A list of subnet IDs to launch the CodeFresh backing services in"
}

# mq modules
#--------------------------------------------------------------
module "amq" {
  source                     = "git::https://github.com/cloudposse/terraform-aws-mq-broker.git?ref=initial_implementation"
  namespace                  = "${var.namespace}"
  stage                      = "${var.stage}"
  name                       = "${var.name}"
  broker_name                = "${var.mq_broker_name}"
  apply_immediately          = "${var.mq_apply_immediately}"
  enabled                    = "${var.mq_enabled}"
  auto_minor_version_upgrade = "${var.mq_auto_minor_version_upgrade}"
  deployment_mode            = "${var.mq_deployment_mode}"
  engine_type                = "${var.mq_engine_type}"
  engine_version             = "${var.mq_engine_version}"
  chamber_service            = "${local.chamber_service}"
  host_instance_type         = "${var.mq_host_instance_type}"
  publicly_accessible        = "${var.mq_publicly_accessible}"
  general_log                = "${var.mq_general_log}"
  audit_log                  = "${var.mq_audit_log}"
  maintenance_day_of_week    = "${var.mq_maintenance_day_of_week}"
  maintenance_time_of_day    = "${var.mq_maintenance_time_of_day}"
  maintenance_time_zone      = "${var.mq_maintenance_time_zone}"
  vpc_id                     = "${var.vpc_id}"
  subnet_ids                 = ["${var.mq_subnet_ids}"]
  security_groups            = ["${var.node_security_groups}"]
}

# mq outputs
#--------------------------------------------------------------
output "mq_broker_id" {
  value = "${module.amq.broker_id}"
}

output "mq_broker_arn" {
  value = "${module.amq.broker_arn}"
}

output "mq_primary_console_url" {
  value = "${module.amq.primary_console_url}"
}

output "mq_primary_ampq_ssl_endpoint" {
  value = "${module.amq.primary_ampq_ssl_endpoint}"
}

output "mq_primary_ip_address" {
  value = "${module.amq.primary_ip_address}"
}

output "mq_secondary_console_url" {
  value = "${module.amq.secondary_console_url}"
}

output "mq_secondary_ampq_ssl_endpoint" {
  value = "${module.amq.secondary_ampq_ssl_endpoint}"
}

output "mq_secondary_ip_address" {
  value = "${module.amq.secondary_ip_address}"
}

output "mq_admin_username" {
  value = "${module.amq.admin_username}"
}

output "mq_application_username" {
  value = "${module.amq.application_username}"
}
