variable "documentdb_cluster_enabled" {
  description = "Set to false to prevent the module from creating DocumentDB cluster"
  default     = "true"
}

variable "documentdb_instance_class" {
  type        = "string"
  default     = "db.r4.large"
  description = "The instance class to use. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs"
}

variable "documentdb_cluster_size" {
  type        = "string"
  default     = "3"
  description = "Number of DB instances to create in the cluster"
}

variable "documentdb_port" {
  type        = "string"
  default     = "27017"
  description = "DocumentDB port"
}

variable "documentdb_chamber_parameters_mapping" {
  type        = "map"
  default     = {}
  description = "Allow to specify keys names for chamber to store values"
}

variable "documentdb_master_username" {
  type        = "string"
  default     = ""
  description = "Username for the master DB user. If left empty, will be generated automatically"
}

variable "documentdb_master_password" {
  type        = "string"
  default     = ""
  description = "Password for the master DB user. If left empty, will be generated automatically. Note that this may show up in logs, and it will be stored in the state file"
}

variable "documentdb_retention_period" {
  type        = "string"
  default     = "5"
  description = "Number of days to retain backups for"
}

variable "documentdb_preferred_backup_window" {
  type        = "string"
  default     = "07:00-09:00"
  description = "Daily time range during which the backups happen"
}

variable "documentdb_cluster_parameters" {
  type = "list"

  default = [
    {
      name  = "tls"
      value = "disabled"
    },
  ]

  description = "List of DB parameters to apply"
}

variable "documentdb_cluster_family" {
  type        = "string"
  default     = "docdb3.6"
  description = "The family of the DocumentDB cluster parameter group. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html"
}

variable "documentdb_engine" {
  type        = "string"
  default     = "docdb"
  description = "The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb`"
}

variable "documentdb_engine_version" {
  type        = "string"
  default     = ""
  description = "The version number of the database engine to use"
}

variable "documentdb_storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted"
  default     = "true"
}

variable "documentdb_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  default     = "true"
}

variable "documentdb_apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  default     = "true"
}

variable "documentdb_enabled_cloudwatch_logs_exports" {
  type        = "list"
  description = "List of log types to export to CloudWatch. The following log types are supported: audit, error, general, slowquery"
  default     = []
}

locals {
  documentdb_cluster_enabled = "${var.enabled == "true" && var.documentdb_cluster_enabled == "true" ? "true" : "false"}"
  documentdb_master_username = "${length(var.documentdb_master_username) > 0 ? var.documentdb_master_username : join("", random_string.documentdb_master_username.*.result)}"
  documentdb_master_password = "${length(var.documentdb_master_password) > 0 ? var.documentdb_master_password : join("", random_string.documentdb_master_password.*.result)}"
  documentdb_connection_uri  = "${format("mongodb://%s:%s@%s:%s",  local.documentdb_master_username, local.documentdb_master_password, module.documentdb_cluster.endpoint, var.documentdb_port)}"
}

module "documentdb_cluster" {
  source                          = "git::https://github.com/cloudposse/terraform-aws-documentdb-cluster.git?ref=tags/0.2.0"
  enabled                         = "${local.documentdb_cluster_enabled}"
  namespace                       = "${var.namespace}"
  stage                           = "${var.stage}"
  name                            = "${var.name}"
  attributes                      = ["${var.attributes}"]
  tags                            = "${var.tags}"
  delimiter                       = "${var.delimiter}"
  cluster_size                    = "${var.documentdb_cluster_size}"
  master_username                 = "${local.documentdb_master_username}"
  master_password                 = "${local.documentdb_master_password}"
  instance_class                  = "${var.documentdb_instance_class}"
  db_port                         = "${var.documentdb_port}"
  vpc_id                          = "${var.vpc_id}"
  subnet_ids                      = ["${var.subnet_ids}"]
  zone_id                         = "${local.zone_id}"
  cluster_dns_name                = "docdb-master.${var.name}"
  reader_dns_name                 = "docdb-replicas.${var.name}"
  allowed_security_groups         = ["${var.security_groups}"]
  apply_immediately               = "${var.documentdb_apply_immediately}"
  enabled_cloudwatch_logs_exports = ["${var.documentdb_enabled_cloudwatch_logs_exports}"]
  skip_final_snapshot             = "${var.documentdb_skip_final_snapshot}"
  storage_encrypted               = "${var.documentdb_storage_encrypted}"
  engine_version                  = "${var.documentdb_engine_version}"
  engine                          = "${var.documentdb_engine}"
  cluster_family                  = "${var.documentdb_cluster_family}"
  cluster_parameters              = ["${var.documentdb_cluster_parameters}"]
  preferred_backup_window         = "${var.documentdb_preferred_backup_window}"
  retention_period                = "${var.documentdb_retention_period}"
}

resource "random_string" "documentdb_master_username" {
  count   = "${local.documentdb_cluster_enabled  == "true" && length(var.documentdb_master_username) == 0 ? 1 : 0}"
  length  = 8
  special = false
  number  = false
}

resource "random_string" "documentdb_master_password" {
  count   = "${local.documentdb_cluster_enabled == "true" && length(var.documentdb_master_password) == 0 ? 1 : 0}"
  length  = 16
  special = true
}

resource "aws_ssm_parameter" "documentdb_master_username" {
  count       = "${local.documentdb_cluster_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, lookup(var.documentdb_chamber_parameters_mapping, "documentdb_master_username", "documentdb_master_username"))}"
  value       = "${local.documentdb_master_username}"
  description = "DocumentDB Username for the master DB user"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "documentdb_master_password" {
  count       = "${local.documentdb_cluster_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, lookup(var.documentdb_chamber_parameters_mapping, "documentdb_master_password", "documentdb_master_password"))}"
  value       = "${local.documentdb_master_password}"
  description = "DocumentDB Password for the master DB user"
  type        = "SecureString"
  key_id      = "${data.aws_kms_key.chamber_kms_key.id}"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "documentdb_master_hostname" {
  count       = "${local.documentdb_cluster_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, lookup(var.documentdb_chamber_parameters_mapping, "documentdb_master_hostname", "documentdb_master_hostname"))}"
  value       = "${module.documentdb_cluster.master_host}"
  description = "DocumentDB DB master hostname"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "documentdb_replicas_hostname" {
  count       = "${local.documentdb_cluster_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, lookup(var.documentdb_chamber_parameters_mapping, "documentdb_replicas_hostname", "documentdb_replicas_hostname"))}"
  value       = "${module.documentdb_cluster.replicas_host}"
  description = "DocumentDB DB replicas hostname"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "documentdb_cluster_name" {
  count       = "${local.documentdb_cluster_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, lookup(var.documentdb_chamber_parameters_mapping, "documentdb_cluster_name", "documentdb_cluster_name"))}"
  value       = "${module.documentdb_cluster.cluster_name}"
  description = "DocumentDB Cluster Identifier"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "documentdb_connection_uri" {
  count       = "${local.documentdb_cluster_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, lookup(var.documentdb_chamber_parameters_mapping, "documentdb_connection_uri", "documentdb_connection_uri"))}"
  value       = "${local.documentdb_connection_uri}"
  description = "DocumentDB connection URI"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

output "documentdb_master_username" {
  value       = "${module.documentdb_cluster.master_username}"
  description = "DocumentDB Username for the master DB user"
}

output "documentdb_cluster_name" {
  value       = "${module.documentdb_cluster.cluster_name}"
  description = "DocumentDB Cluster Identifier"
}

output "documentdb_arn" {
  value       = "${module.documentdb_cluster.arn}"
  description = "Amazon Resource Name (ARN) of the DocumentDB cluster"
}

output "documentdb_endpoint" {
  value       = "${module.documentdb_cluster.endpoint}"
  description = "Endpoint of the DocumentDB cluster"
}

output "documentdb_reader_endpoint" {
  value       = "${module.documentdb_cluster.reader_endpoint}"
  description = "Read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas"
}

output "documentdb_master_host" {
  value       = "${module.documentdb_cluster.master_host}"
  description = "DocumentDB master hostname"
}

output "documentdb_replicas_host" {
  value       = "${module.documentdb_cluster.replicas_host}"
  description = "DocumentDB replicas hostname"
}
