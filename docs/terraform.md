
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| aws_assume_role_arn |  | string | - | yes |
| chamber_format | Format to store parameters in SSM, for consumption with chamber | string | `/%s/%s` | no |
| chamber_service | `chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details | string | `` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| efs_enabled | Set to false to prevent the module from creating any resources | string | `` | no |
| enabled | Set to false to prevent the module from creating any resources | string | `true` | no |
| kms_key_id | KMS key id used to encrypt SSM parameters | string | `` | no |
| mq_apply_immediately | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window | string | `true` | no |
| mq_audit_log | Enables audit logging. User management action made using JMX or the ActiveMQ Web Console is logged | string | `true` | no |
| mq_auto_minor_version_upgrade | Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions | string | `false` | no |
| mq_deployment_mode | The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ | string | `ACTIVE_STANDBY_MULTI_AZ` | no |
| mq_enabled | Set to false to prevent the module from creating any resources | string | `` | no |
| mq_engine_type | The type of broker engine. Currently, Amazon MQ supports only ActiveMQ | string | `ActiveMQ` | no |
| mq_engine_version | The version of the broker engine. Currently, Amazon MQ supports only 5.15.0 or 5.15.6. | string | `5.15.0` | no |
| mq_general_log | Enables general logging via CloudWatch | string | `true` | no |
| mq_host_instance_type | The broker's instance type. e.g. mq.t2.micro or mq.m4.large | string | `mq.t2.micro` | no |
| mq_maintenance_day_of_week | The day of the week. e.g. MONDAY, TUESDAY, or WEDNESDAY | string | `SUNDAY` | no |
| mq_maintenance_time_of_day | The time, in 24-hour format. e.g. 02:00 | string | `03:00` | no |
| mq_maintenance_time_zone | The time zone, in either the Country/City format, or the UTC offset format. e.g. CET | string | `UTC` | no |
| mq_publicly_accessible | Whether to enable connections from applications outside of the VPC that hosts the broker's subnets. | string | `false` | no |
| name | Name  (e.g. `codefresh`) | string | `codefresh` | no |
| namespace | Namespace (e.g. `eg` or `cp`) | string | - | yes |
| overwrite_ssm_parameter | Whether to overwrite an existing SSM parameter | string | `true` | no |
| postgres_admin_password | Postgres password for the admin user | string | `` | no |
| postgres_admin_user | Postgres admin user name | string | `` | no |
| postgres_cluster_enabled | Set to false to prevent the module from creating any resources | string | `` | no |
| postgres_cluster_family | Postgres cluster DB family. Currently supported values are `aurora-postgresql9.6` and `aurora-postgresql10` | string | `aurora-postgresql9.6` | no |
| postgres_cluster_size | Postgres cluster size | string | `2` | no |
| postgres_db_name | Postgres database name | string | `` | no |
| postgres_instance_type | EC2 instance type for Postgres cluster | string | `db.r4.large` | no |
| postgres_maintenance_window | Weekly time range during which system maintenance can occur, in UTC | string | `sun:03:00-sun:04:00` | no |
| redis_apply_immediately | Whether to apply changes immediately or during the next maintenance_window | string | `true` | no |
| redis_at_rest_encryption_enabled | Enable Redis encryption at rest | string | `true` | no |
| redis_auth_token | Auth token for password protecting redis, transit_encryption_enabled must be set to 'true'! Password must be longer than 16 chars | string | `` | no |
| redis_automatic_failover | Whether to enable automatic_failover | string | `true` | no |
| redis_cluster_enabled | Set to false to prevent the module from creating any resources | string | `` | no |
| redis_cluster_size | Redis cluster size | string | `2` | no |
| redis_engine_version | Version of Redis engine | string | `3.2.6` | no |
| redis_instance_type | EC2 instance type for Redis cluster | string | `cache.t2.medium` | no |
| redis_maintenance_window | Weekly time range during which system maintenance can occur, in UTC | string | `sun:03:00-sun:04:00` | no |
| redis_params | A list of Redis parameters to apply. Note that parameters may differ from a Redis family to another | list | `<list>` | no |
| redis_transit_encryption_enabled | Enable TLS | string | `true` | no |
| s3_access_key_name | S3 user IAM access key name for storing in SSM. Default to aws_acces_key_id so chamber exports as AWS_ACCESS_KEY_ID, a standard AWS IAM ENV variable | string | `aws_access_key_id` | no |
| s3_allowed_bucket_actions | List of actions to permit for S3 bucket | list | `<list>` | no |
| s3_enabled | Set to false to prevent the module from creating any resources | string | `` | no |
| s3_secret_key_name | S3 user IAM secret key name for storing in SSM. Default to aws_secret_acces_key so chamber exports as AWS_SECRET_ACCESS_KEY, a standard AWS IAM ENV variable | string | `aws_secret_access_key` | no |
| s3_user_enabled | Set to `true` to create an S3 user with permission to access the bucket | string | `` | no |
| s3_versioning_enabled | Whether to enable versioning on the S3 bucket. | string | `false` | no |
| security_groups | List of security groups to be allowed to connect to the CodeFresh backing services | list | `<list>` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| subnet_ids | A list of subnet IDs to launch the CodeFresh backing services in | list | `<list>` | no |
| tags | Additional tags (e.g. map(`Cluster`,`us-east-1.cloudposse.co`) | map | `<map>` | no |
| vpc_id | VPC ID for the CodeFresh backing services | string | - | yes |
| zone_name | DNS zone name | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| aurora_postgres_cluster_name | Aurora Postgres Cluster Identifier |
| aurora_postgres_database_name | Aurora Postgres Database name |
| aurora_postgres_master_hostname | Aurora Postgres DB Master hostname |
| aurora_postgres_master_username | Aurora Postgres Username for the master DB user |
| aurora_postgres_replicas_hostname | Aurora Postgres Replicas hostname |
| efs_arn | EFS arn |
| efs_dns_name | EFS DNS name |
| efs_host | EFS host |
| efs_id | EFS ID |
| efs_mount_target_dns_names | EFS mount target DNS names |
| efs_mount_target_ids | EFS mount target IDs |
| efs_mount_target_ips | EFS mount target IPs |
| efs_network_interface_ids | EFS network interface IDs |
| elasticache_redis_host | Elasticache Redis host |
| elasticache_redis_id | Elasticache Redis cluster ID |
| elasticache_redis_security_group_id | Elasticache Redis security group ID |
| mq_admin_username | AmazonMQ admin username |
| mq_application_username | AmazonMQ application username |
| mq_broker_arn | AmazonMQ broker ARN |
| mq_broker_id | AmazonMQ broker ID |
| mq_primary_ampq_ssl_endpoint | AmazonMQ primary AMQP+SSL endpoint |
| mq_primary_console_url | AmazonMQ active web console URL |
| mq_primary_ip_address | AmazonMQ primary IP address |
| mq_secondary_ampq_ssl_endpoint | AmazonMQ secondary AMQP+SSL endpoint |
| mq_secondary_console_url | AmazonMQ secondary web console URL |
| mq_secondary_ip_address | AmazonMQ secondary IP address |
| s3_access_key_id | The access key ID |
| s3_bucket_arn | The s3 bucket ARN |
| s3_secret_access_key | The secret access key. This will be written to the state file in plain-text |
| s3_user_arn | The ARN assigned by AWS for the user |
| s3_user_name | Normalized IAM user name |
| s3_user_unique_id | The user unique ID assigned by AWS |

