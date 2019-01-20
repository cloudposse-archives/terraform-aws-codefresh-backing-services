provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = "${var.attributes}"
  tags       = "${local.tags}"
  cidr_block = "${var.vpc_cidr_block}"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master"
  availability_zones  = ["${var.availability_zones}"]
  namespace           = "${var.namespace}"
  stage               = "${var.stage}"
  name                = "${var.name}"
  attributes          = "${var.attributes}"
  tags                = "${local.tags}"
  region              = "${var.region}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"
}

module "codefresh_backing_services" {
  source          = "git::https://github.com/cloudposse/terraform-aws-codefresh-backing-services.git?ref=master"
  enabled         = "true"
  name            = "${var.name}"
  namespace       = "${var.namespace}"
  region          = "${var.region}"
  stage           = "${var.stage}"
  vpc_id          = "${module.vpc.vpc_id}"
  subnet_ids      = ["${module.subnets.private_subnet_ids}"]
  security_groups = ["${module.vpc.vpc_default_security_group_id}"]

  chamber_format  = "/%s/%s"
  chamber_service = "codefresh-backing-services"
  kms_key_id      = "${format("alias/%s-%s-chamber", var.namespace, var.stage)}"

  efs_enabled = "false"

  s3_enabled = "false"

  mq_apply_immediately          = "false"
  mq_audit_log                  = "false:"
  mq_auto_minor_version_upgrade = "true"
  mq_deployment_mode            = "ACTIVE_STANDBY_MULTI_AZ"
  mq_engine_type                = "ActiveMQ"
  mq_engine_version             = "5.15.0"
  mq_general_log                = "true"
  mq_host_instance_type         = "mq.t2.micro"
  mq_maintenance_day_of_week    = "MONDAY"
  mq_maintenance_time_of_day    = "02:00"
  mq_maintenance_time_zone      = "CET"
  mq_publicly_accessible        = "false"
  mq_subnet_ids                 = "${local.mq_subnet_ids}"

  postgres_admin_password     = "mypostgrespassword"
  postgres_admin_user         = "userformyawesomeapp"
  postgres_instance_type      = "db.r4.large"
  postgres_maintenance_window = "mon:03:00-mon:04:00"
  postgres_name               = "my_app"
  postgres_db_name            = "db1"

  redis_at_rest_encryption_enabled = "true"
  redis_auth_token                 = "myawesomeauthtoken"
  redis_automatic_failover         = "true"
  redis_cluster_size               = "2"
  redis_engine_version             = "3.2.6"
  redis_instance_type              = "cache.t2.medium"
  redis_name                       = "rediscacheformyawesomeapp"
}
