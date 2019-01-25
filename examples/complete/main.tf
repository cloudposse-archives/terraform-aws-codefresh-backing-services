provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=0.3.6"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = "${var.attributes}"
  tags       = "${local.tags}"
  cidr_block = "${var.vpc_cidr_block}"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=0.4.0"
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
  source          = "git::https://github.com/cloudposse/terraform-aws-codefresh-backing-services.git?ref=0.1.0"
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

  postgres_instance_type      = "db.r4.large"
  postgres_maintenance_window = "mon:03:00-mon:04:00"
  postgres_name               = "my_app"
  postgres_db_name            = "db1"

  redis_automatic_failover         = "true"
  redis_cluster_size               = "2"
  redis_engine_version             = "3.2.6"
  redis_instance_type              = "cache.t2.medium"
  redis_name                       = "rediscacheformyawesomeapp"
}
