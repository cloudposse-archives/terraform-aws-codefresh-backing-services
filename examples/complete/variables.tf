variable "namespace" {
  type        = "string"
  default     = "eg"
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = "string"
  default     = "testing"
  description = "Stage, e.g. 'prod', 'staging', 'dev' or 'testing'"
}

variable "name" {
  type        = "string"
  default     = "codefresh"
  description = "Solution name, e.g. 'codefresh' or 'cf'"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "region" {
  type        = "string"
  default     = "us-west-2"
  description = "AWS Region"
}

variable "vpc_cidr_block" {
  type        = "string"
  default     = "172.30.0.0/16"
  description = "VPC CIDR block. See https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html for more details"
}

variable "availability_zones" {
  type        = "list"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
  description = "Availability Zones for the cluster"
}
