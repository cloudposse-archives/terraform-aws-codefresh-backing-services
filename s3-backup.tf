variable "backup_enabled" {
  type        = "string"
  default     = ""
  description = "Set to false to prevent the module from creating any resources"
}

variable "backup_s3_user_enabled" {
  type        = "string"
  default     = ""
  description = "Set to `true` to create an backup_s3 user with permission to access the bucket"
}

variable "backup_s3_allowed_bucket_actions" {
  type        = "list"
  default     = ["backup_s3:PutObject", "backup_s3:PutObjectAcl", "backup_s3:GetObject", "backup_s3:DeleteObject", "backup_s3:ListBucket", "backup_s3:ListBucketMultipartUploads", "backup_s3:GetBucketLocation", "backup_s3:AbortMultipartUpload"]
  description = "List of actions to permit for backup_s3 bucket"
}

variable "backup_s3_access_key_name" {
  type        = "string"
  default     = "backup_aws_access_key_id"
  description = "backup_s3 user IAM access key name for storing in SSM. Default to aws_acces_key_id so chamber exports as AWS_ACCESS_KEY_ID, a standard AWS IAM ENV variable"
}

variable "backup_s3_secret_key_name" {
  type        = "string"
  default     = "backup_aws_secret_access_key"
  description = "backup_s3 user IAM secret key name for storing in SSM. Default to aws_secret_acces_key so chamber exports as AWS_SECRET_ACCESS_KEY, a standard AWS IAM ENV variable "
}

locals {
  backup_s3_enabled      = "${var.backup_enabled != "" ? var.backup_enabled : var.enabled}"
  backup_s3_user_enabled = "${var.backup_s3_user_enabled != "" ? var.backup_s3_user_enabled :  var.enabled}"
}

module "backup_s3_bucket" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=tags/0.2.0"
  enabled                = "${local.backup_s3_enabled}"
  user_enabled           = "${local.backup_s3_user_enabled}"
  versioning_enabled     = "false"
  allowed_bucket_actions = "${var.backup_s3_allowed_bucket_actions}"
  name                   = "${var.name}"
  stage                  = "${var.stage}"
  namespace              = "${var.namespace}"
  attributes             = "${concat(var.attributes, list("backup"))}"
}

resource "aws_ssm_parameter" "backup_s3_user_iam_access_key_id" {
  count       = "${local.backup_s3_enabled == "true" && local.backup_s3_user_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, var.backup_s3_access_key_name)}"
  value       = "${module.backup_s3_bucket.access_key_id}"
  description = "backup_s3 user aws_access_key_id"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "backup_s3_user_iam_secret_access_key" {
  count       = "${local.backup_s3_enabled == "true" && local.backup_s3_user_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, var.backup_s3_secret_key_name)}"
  value       = "${module.backup_s3_bucket.secret_access_key}"
  description = "backup_s3 user aws_secret_acces_key"
  type        = "SecureString"
  key_id      = "${data.aws_kms_key.chamber_kms_key.id}"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

output "backup_s3_user_name" {
  value       = "${module.backup_s3_bucket.user_name}"
  description = "Normalized IAM user name"
}

output "backup_s3_user_arn" {
  value       = "${module.backup_s3_bucket.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "backup_s3_user_unique_id" {
  value       = "${module.backup_s3_bucket.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "backup_s3_access_key_id" {
  sensitive   = true
  value       = "${module.backup_s3_bucket.access_key_id}"
  description = "The access key ID"
}

output "backup_s3_secret_access_key" {
  sensitive   = true
  value       = "${module.backup_s3_bucket.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}

output "backup_s3_bucket_arn" {
  value       = "${module.backup_s3_bucket.s3_bucket_arn}"
  description = "The backup_s3 bucket ARN"
}
