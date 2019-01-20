terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "name" {
  type        = "string"
  description = "Name  (e.g. `codefresh`)"
  default     = "codefresh"
}

variable "namespace" {
  type        = "string"
  description = "Namespace (e.g. `eg` or `cp`)"
}

variable "stage" {
  type        = "string"
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
}

variable "zone_name" {
  type        = "string"
  description = "DNS zone name"
}

variable "kms_key_id" {
  type        = "string"
  default     = ""
  description = "KMS key id used to encrypt SSM parameters"
}

variable "chamber_format" {
  default     = "/%s/%s"
  description = "Format to store parameters in SSM, for consumption with chamber"
}

variable "chamber_service" {
  default     = ""
  description = "`chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details"
}

variable "overwrite_ssm_parameter" {
  type        = "string"
  default     = "true"
  description = "Whether to overwrite an existing SSM parameter"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map(`Cluster`,`us-east-1.cloudposse.co`)"
}

variable "security_groups" {
  type        = "list"
  default     = []
  description = "List of security groups to be allowed to connect to the CodeFresh backing services"
}

variable "subnet_ids" {
  type        = "list"
  default     = []
  description = "A list of subnet IDs to launch the CodeFresh backing services in"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC ID for the CodeFresh backing services"
}

variable "enabled" {
  type        = "string"
  default     = "true"
  description = "Set to false to prevent the module from creating any resources"
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.5"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
  enabled    = "${var.enabled}"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_route53_zone" "default" {
  name = "${var.zone_name}"
}

data "aws_kms_key" "chamber_kms_key" {
  key_id = "${local.kms_key_id}"
}

locals {
  kms_key_id      = "${length(var.kms_key_id) > 0 ? var.kms_key_id : format("alias/%s-%s-chamber", var.namespace, var.stage)}"
  chamber_service = "${var.chamber_service == "" ? basename(pathexpand(path.module)) : var.chamber_service}"
  zone_id         = "${data.aws_route53_zone.default.zone_id}"
}
