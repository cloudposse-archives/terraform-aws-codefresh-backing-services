variable "mq_apply_immediately" {
  type        = "string"
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  default     = "true"
}

variable "mq_enabled" {
  type        = "string"
  default     = ""
  description = "Set to false to prevent the module from creating any resources"
}

variable "mq_auto_minor_version_upgrade" {
  type        = "string"
  description = "Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions"
  default     = "false"
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

# Running ActiveMQ in ACTIVE_STANDBY_MULTI_AZ mode requires you only
# supply 2 subnets. Any more and the resource will complain. Similarly
# you must pass a single subnet if running in SINGLE_INSTANCE mode
locals {
  mq_enabled    = "${var.mq_enabled != "" ? var.mq_enabled : var.enabled}"
  mq_subnet_ids = "${var.mq_deployment_mode == "ACTIVE_STANDBY_MULTI_AZ" ? slice(var.subnet_ids,0,2) : slice(var.subnet_ids,0,1)}"
}

module "amq" {
  source                     = "git::https://github.com/cloudposse/terraform-aws-mq-broker.git?ref=tags/0.2.0"
  namespace                  = "${var.namespace}"
  stage                      = "${var.stage}"
  name                       = "${var.name}"
  apply_immediately          = "${var.mq_apply_immediately}"
  enabled                    = "${local.mq_enabled}"
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
  subnet_ids                 = ["${local.mq_subnet_ids}"]
  security_groups            = ["${var.security_groups}"]
}

output "mq_broker_id" {
  value       = "${local.mq_enabled ? module.amq.broker_id : ""}"
  description = "AmazonMQ broker ID"
}

output "mq_broker_arn" {
  value       = "${local.mq_enabled ? module.amq.broker_arn : ""}"
  description = "AmazonMQ broker ARN"
}

output "mq_primary_console_url" {
  value       = "${local.mq_enabled ? module.amq.primary_console_url : ""}"
  description = "AmazonMQ active web console URL"
}

output "mq_primary_ampq_ssl_endpoint" {
  value       = "${local.mq_enabled ?  module.amq.primary_ampq_ssl_endpoint : ""}"
  description = "AmazonMQ primary AMQP+SSL endpoint"
}

output "mq_primary_ip_address" {
  value       = "${local.mq_enabled ? module.amq.primary_ip_address : ""}"
  description = "AmazonMQ primary IP address"
}

output "mq_secondary_console_url" {
  value       = "${local.mq_enabled ? module.amq.secondary_console_url : ""}"
  description = "AmazonMQ secondary web console URL"
}

output "mq_secondary_ampq_ssl_endpoint" {
  value       = "${local.mq_enabled ? module.amq.secondary_ampq_ssl_endpoint : ""}"
  description = "AmazonMQ secondary AMQP+SSL endpoint"
}

output "mq_secondary_ip_address" {
  value       = "${local.mq_enabled ? module.amq.secondary_ip_address : ""}"
  description = "AmazonMQ secondary IP address"
}

output "mq_admin_username" {
  value       = "${local.mq_enabled ? module.amq.admin_username : ""}"
  description = "AmazonMQ admin username"
}

output "mq_application_username" {
  value       = "${local.mq_enabled ? module.amq.application_username : ""}"
  description = "AmazonMQ application username"
}
