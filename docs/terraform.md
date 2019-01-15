
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| aws_assume_role_arn | global variables -------------------------------------------------------------- | string | - | yes |
| chamber_parameter_name |  | string | `/%s/%s` | no |
| chamber_service | `chamber` service name. See [chamber usage](https://github.com/segmentio/chamber#usage) for more details | string | `` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| kms_key_id | KMS key id used to encrypt SSM parameters | string | `` | no |
| kops_metadata_enabled | Set to false to prevent the module from creating any resources | string | `false` | no |
| mq_admin_password | Admin password | string | `` | no |
| mq_admin_user | Admin username | string | `` | no |
| mq_apply_immediately | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window | string | `true` | no |
| mq_audit_log | Enables audit logging. User management action made using JMX or the ActiveMQ Web Console is logged | string | `true` | no |
| mq_auto_minor_version_upgrade | Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions | string | `false` | no |
| mq_broker_name | The name of the broker | string | `mq` | no |
| mq_config_template_path | Path to ActiveMQ XML config | string | `` | no |
| mq_configuration_name | The name of the MQ configuration | string | `mq` | no |
| mq_deployment_mode | The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ | string | `ACTIVE_STANDBY_MULTI_AZ` | no |
| mq_enabled | Set to false to prevent the module from creating any resources | string | `true` | no |
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
| postgres_cluster_enabled | Set to false to prevent the module from creating any resources | string | `true` | no |
| postgres_cluster_family | Postgres cluster DB family. Currently supported values are aurora-postgresql9.6 / aurora-postgresql10 | string | `aurora-postgresql9.6` | no |
| postgres_cluster_size | Postgres cluster size | string | `2` | no |
| postgres_db_name | Postgres database name | string | `` | no |
| postgres_instance_type | EC2 instance type for Postgres cluster | string | `db.r4.large` | no |
| postgres_maintenance_window | Weekly time range during which system maintenance can occur, in UTC | string | `sun:03:00-sun:04:00` | no |
| postgres_name | Name of the application, e.g. `app` or `analytics` | string | `` | no |
| postgres_replica_cluster_identifier | The cluster identifier | string | `` | no |
| postgres_replica_cluster_size | Postgres cluster size | string | `2` | no |
| postgres_replica_enabled | Set to false to prevent the module from creating any resources | string | `true` | no |
| postgres_replica_instance_type | EC2 instance type for Postgres cluster | string | `db.r4.large` | no |
| postgres_replica_name | Name of the replica, e.g. `postgres` or `reporting` | string | `` | no |
| redis_auth_token | Auth token for password protecting redis, transit_encryption_enabled must be set to 'true'! Password must be longer than 16 chars | string | `` | no |
| redis_automatic_failover | Whether to enable automatic_failover | string | `true` | no |
| redis_cluster_enabled | Set to false to prevent the module from creating any resources | string | `false` | no |
| redis_cluster_size | Redis cluster size | string | `2` | no |
| redis_engine_version | Version of Redis engine | string | `3.2.6` | no |
| redis_instance_type | EC2 instance type for Redis cluster | string | `cache.t2.medium` | no |
| redis_maintenance_window | Weekly time range during which system maintenance can occur, in UTC | string | `sun:03:00-sun:04:00` | no |
| redis_name | Redis name | string | `redis` | no |
| redis_params | A list of Redis parameters to apply. Note that parameters may differ from a Redis family to another | list | `<list>` | no |
| redis_transit_encryption_enabled | Enable TLS | string | `true` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| tags | Additional tags (e.g. map(`Cluster`,`us-east-1.cloudposse.co`) | map | `<map>` | no |
| vpc_cidr_block | vpc variables -------------------------------------------------------------- | string | `10.0.0.0/16` | no |
| vpc_nat_gateway_enabled |  | string | `true` | no |
| zone_name | DNS zone name | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| aurora_postgres_cluster_name | Aurora Postgres Cluster Identifier |
| aurora_postgres_database_name | aurora-postgres outputs -------------------------------------------------------------- |
| aurora_postgres_master_hostname | Aurora Postgres DB Master hostname |
| aurora_postgres_master_username | Aurora Postgres Username for the master DB user |
| aurora_postgres_replicas_hostname | Aurora Postgres Replicas hostname |
| elasticache_redis_host |  |
| elasticache_redis_id | elasticache-redis outputs -------------------------------------------------------------- |
| elasticache_redis_security_group_id |  |
| mq_broker_arn |  |
| mq_broker_id | mq resources -------------------------------------------------------------- |
| mq_broker_instances |  |
| postgres_replica_endpoint | RDS Cluster replica endpoint |
| postgres_replica_hostname | aurora-postgres-replica outputs -------------------------------------------------------------- |
| region | AWS region of backing services |
| vpc_id | vpc outputs -------------------------------------------------------------- |

