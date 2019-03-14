variable "acm_enabled" {
  description = "Set to false to prevent the acm module from creating any resources"
  default     = "true"
}

variable "acm_primary_domain" {
  description = "A domain name for which the certificate should be issued"
}

variable "acm_san_domains" {
  type = "list"
  default =  []
  description = "A list of domains that should be SANs in the issued certificate"
}

variable "acm_ttl" {
  default = 300
  description = "The TTL of the record to add to the DNS zone to complete certificate validation"
}

variable "acm_zone_name" {
  type        = "string"
  default     = ""
  description = "The name of the desired Route53 Hosted Zone"
}

module "acm_request_certificate" {
  source                            = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=add/enabled-var"
  enabled                           = "${var.acm_enabled}"
  domain_name                       = "${var.acm_primary_domain}"
  process_domain_validation_options = "true"
  ttl                               = "${var.acm_ttl}"
  subject_alternative_names         = ["${var.acm_san_domains}"]
  zone_name                         = "${var.acm_zone_name}"
}

output "acm_id" {
  value       = "${module.acm_request_certificate.id}"
  description = "The ARN of the certificate"
}

output "acm_arn" {
  value       = "${module.acm_request_certificate.arn}"
  description = "The ARN of the certificate"
}

output "acm_domain_validation_options" {
  value       = "${module.acm_request_certificate.domain_validation_options}"
  description = "CNAME records that are added to the DNS zone to complete certificate validation"
}

output "acm_email_validation_options" {
  value       = ["${module.acm_request_certificate.email_validation_options}"]
  description = " A list of addresses that received a validation E-Mail"
}
