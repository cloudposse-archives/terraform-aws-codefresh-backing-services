variable "s3_enabled" {
  type        = "string"
  default     = ""
  description = "Set to false to prevent the module from creating any resources"
}

variable "s3_user_enabled" {
  type        = "string"
  default     = ""
  description = "Set to `true` to create an S3 user with permission to access the bucket"
}

variable "s3_versioning_enabled" {
  type        = "string"
  default     = "false"
  description = "Whether to enable versioning on the S3 bucket."
}

variable "s3_allowed_bucket_actions" {
  type        = "list"
  default     = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  description = "List of actions to permit for S3 bucket"
}

variable "s3_access_key_name" {
  type        = "string"
  default     = "aws_access_key_id"
  description = "S3 user IAM access key name for storing in SSM. Default to aws_acces_key_id so chamber exports as AWS_ACCESS_KEY_ID, a standard AWS IAM ENV variable"
}

variable "s3_secret_key_name" {
  type        = "string"
  default     = "aws_secret_access_key"
  description = "S3 user IAM secret key name for storing in SSM. Default to aws_secret_acces_key so chamber exports as AWS_SECRET_ACCESS_KEY, a standard AWS IAM ENV variable "
}

locals {
  s3_enabled      = "${var.s3_enabled != "" ? var.s3_enabled : var.enabled}"
  s3_user_enabled = "${var.s3_user_enabled != "" ? var.s3_user_enabled :  var.enabled}"
}

module "s3_bucket" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=tags/0.2.0"
  enabled                = "${local.s3_enabled}"
  user_enabled           = "${local.s3_user_enabled}"
  versioning_enabled     = "${var.s3_versioning_enabled}"
  allowed_bucket_actions = "${var.s3_allowed_bucket_actions}"
  name                   = "${var.name}"
  stage                  = "${var.stage}"
  namespace              = "${var.namespace}"
}

resource "aws_ssm_parameter" "s3_user_iam_access_key_id" {
  count       = "${local.s3_enabled == "true" && local.s3_user_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, var.s3_access_key_name)}"
  value       = "${module.s3_bucket.access_key_id}"
  description = "S3 user aws_access_key_id"
  type        = "String"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

resource "aws_ssm_parameter" "s3_user_iam_secret_access_key" {
  count       = "${local.s3_enabled == "true" && local.s3_user_enabled == "true" ? 1 : 0}"
  name        = "${format(var.chamber_format, local.chamber_service, var.s3_secret_key_name)}"
  value       = "${module.s3_bucket.secret_access_key}"
  description = "S3 user aws_secret_acces_key"
  type        = "SecureString"
  key_id      = "${data.aws_kms_key.chamber_kms_key.id}"
  overwrite   = "${var.overwrite_ssm_parameter}"
}

output "s3_user_name" {
  value       = "${module.s3_bucket.user_name}"
  description = "Normalized IAM user name"
}

output "s3_user_arn" {
  value       = "${module.s3_bucket.user_arn}"
  description = "The ARN assigned by AWS for the user"
}

output "s3_user_unique_id" {
  value       = "${module.s3_bucket.user_unique_id}"
  description = "The user unique ID assigned by AWS"
}

output "s3_access_key_id" {
  sensitive   = true
  value       = "${module.s3_bucket.access_key_id}"
  description = "The access key ID"
}

output "s3_secret_access_key" {
  sensitive   = true
  value       = "${module.s3_bucket.secret_access_key}"
  description = "The secret access key. This will be written to the state file in plain-text"
}

output "s3_bucket_arn" {
  value       = "${module.s3_bucket.s3_bucket_arn}"
  description = "The s3 bucket ARN"
}
