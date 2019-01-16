variable "redis_name" {
  type        = "string"
  default     = "redis"
  description = "Redis name"
}

variable "redis_instance_type" {
  type        = "string"
  default     = "cache.t2.medium"
  description = "EC2 instance type for Redis cluster"
}

variable "redis_cluster_size" {
  type        = "string"
  default     = "2"
  description = "Redis cluster size"
}

variable "redis_cluster_enabled" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

variable "redis_auth_token" {
  type        = "string"
  default     = ""
  description = "Auth token for password protecting redis, transit_encryption_enabled must be set to 'true'! Password must be longer than 16 chars"
}

variable "redis_engine_version" {
  type        = "string"
  default     = "3.2.6"
  description = "Version of Redis engine"
}

variable "redis_transit_encryption_enabled" {
  type        = "string"
  default     = "true"
  description = "Enable TLS"
}

variable "redis_at_rest_encryption_enabled" {
  type        = "string"
  default     = "true"
  description = "Enable Redis encryption at rest"
}

variable "redis_params" {
  type        = "list"
  default     = []
  description = "A list of Redis parameters to apply. Note that parameters may differ from a Redis family to another"
}

variable "redis_maintenance_window" {
  type        = "string"
  default     = "sun:03:00-sun:04:00"
  description = "Weekly time range during which system maintenance can occur, in UTC"
}

variable "redis_automatic_failover" {
  type        = "string"
  default     = "true"
  description = "Whether to enable automatic_failover"
}

variable "redis_apply_immediately" {
  type        = "string"
  default     = "true"
  description = "Whether to apply changes immediately or during the next maintenance_window"
}

locals {
  redis_family     = "${format("redis%s", join(".", slice(split(".", var.redis_engine_version),0,2)))}"
  redis_auth_token = "${length(var.redis_auth_token) > 0 ? var.redis_auth_token : join("", random_string.redis_auth_token.*.result)}"
}

resource "random_string" "redis_auth_token" {
  count   = "${var.redis_cluster_enabled ? 1 : 0}"
  length  = 16
  special = "false"
}

resource "aws_ssm_parameter" "redis_auth_token" {
  count       = "${var.redis_cluster_enabled ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, "redis_auth_token")}"
  value       = "${local.redis_auth_token}"
  description = "Redis Elasticache auth token"
  type        = "SecureString"
  key_id      = "${data.aws_kms_key.chamber_kms_key.id}"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

module "elasticache_redis" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=tags/0.9.0"
  namespace                    = "${var.namespace}"
  stage                        = "${var.stage}"
  name                         = "${var.redis_name}"
  zone_id                      = "${local.zone_id}"
  security_groups              = ["${var.node_security_groups}"]
  vpc_id                       = "${var.vpc_id}"
  subnets                      = ["${var.subnet_ids}"]
  maintenance_window           = "${var.redis_maintenance_window}"
  cluster_size                 = "${var.redis_cluster_size}"
  auth_token                   = "${local.redis_auth_token}"
  instance_type                = "${var.redis_instance_type}"
  transit_encryption_enabled   = "${var.redis_transit_encryption_enabled}"
  engine_version               = "${var.redis_engine_version}"
  family                       = "${local.redis_family}"
  port                         = "6379"
  alarm_cpu_threshold_percent  = "75"
  alarm_memory_threshold_bytes = "10000000"
  apply_immediately            = "${var.redis_apply_immediately}"
  at_rest_encryption_enabled   = "${var.redis_at_rest_encryption_enabled}"
  availability_zones           = ["${data.aws_availability_zones.available.names}"]
  automatic_failover           = "${var.redis_automatic_failover}"
  enabled                      = "${var.redis_cluster_enabled}"
  parameter                    = "${var.redis_params}"
}

output "elasticache_redis_id" {
  value       = "${module.elasticache_redis.id}"
  description = "Elasticache Redis cluster ID"
}

output "elasticache_redis_security_group_id" {
  value       = "${module.elasticache_redis.security_group_id}"
  description = "Elasticache Redis security group ID"
}

output "elasticache_redis_host" {
  value       = "${module.elasticache_redis.host}"
  description = "Elasticache Redis host"
}
