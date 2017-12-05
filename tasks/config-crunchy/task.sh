#!/bin/bash -ex

chmod +x om-cli/om-linux
OM_CMD=./om-cli/om-linux

chmod +x ./jq/jq-linux64
JQ_CMD=./jq/jq-linux64

PRODUCT_NETWORK_CONFIG=$(
  echo "{}" |
  $JQ_CMD -n \
    --arg singleton_jobs_az "$SINGLETON_JOBS_AZ" \
    --arg other_azs "$OTHER_AZS" \
    --arg network_name "$NETWORK_NAME" \
    --arg services_network_name "$SERVICES_NETWORK_NAME" \
    '. +
    {
      "singleton_availability_zone": {
        "name": $singleton_jobs_az
      },
      "other_availability_zones": ($other_azs | split(",") | map({name: .})),
      "network": {
        "name": $network_name
      },
      "service_network": {
        "name": $services_network_name
      }
    }
    '
)

$OM_CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k configure-product -n $PRODUCT_IDENTIFIER -pn "$PRODUCT_NETWORK_CONFIG"

PRODUCT_PROPERTIES=$(
  echo "{}" |
      $JQ_CMD -n \
  --arg az_multi_select "$AZ_MULTI_SELECT" \
  --arg consul_server_vm_type "$CONSUL_SERVER_VM_TYPE" \
  --arg consul_server_disk_type "$CONSUL_SERVER_DISK_TYPE" \
  --argjson consul_server_instance_count $CONSUL_SERVER_INSTANCE_COUNT \
  --arg postgresql_haproxy_vm_type "$POSTGRESQL_HAPROXY_VM_TYPE" \
  --arg postgresql_haproxy_disk_type "$POSTGRESQL_HAPROXY_DISK_TYPE" \
  --arg smoke_tests_vm_type "$SMOKE_TESTS_VM_TYPE" \
  --arg smoke_tests_disk_type "$SMOKE_TESTS_DISK_TYPE" \
  --arg small_vm_type "$SMALL_VM_TYPE" \
  --arg small_disk_type "$SMALL_DISK_TYPE" \
  --argjson small_postgresql_instance_count $SMALL_POSTGRESQL_INSTANCE_COUNT \
  --argjson small_postgresql_service_quota $SMALL_POSTGRESQL_SERVICE_QUOTA \
  --arg medium_vm_type "$MEDIUM_VM_TYPE" \
  --arg medium_disk_type "$MEDIUM_DISK_TYPE" \
  --argjson medium_postgresql_instance_count $MEDIUM_POSTGRESQL_INSTANCE_COUNT \
  --argjson medium_postgresql_service_quota $MEDIUM_POSTGRESQL_SERVICE_QUOTA \
  --arg large_vm_type "$LARGE_VM_TYPE" \
  --arg large_disk_type "$LARGE_DISK_TYPE" \
  --argjson large_postgresql_instance_count $LARGE_POSTGRESQL_INSTANCE_COUNT \
  --argjson large_postgresql_service_quota $LARGE_POSTGRESQL_SERVICE_QUOTA \
  --arg extra-large_vm_type "$EXTRA_LARGE_VM_TYPE" \
  --arg extra-large_disk_type "$EXTRA_LARGE_DISK_TYPE" \
  --argjson extra-large_postgresql_instance_count $EXTRA_LARGE_POSTGRESQL_INSTANCE_COUNT \
  --argjson extra-large_postgresql_service_quota $EXTRA_LARGE_POSTGRESQL_SERVICE_QUOTA \
  --arg crunchy_broker_instance_type "$CRUNCHY_BROKER_INSTANCE_TYPE" \
  --arg crunchy_broker_instances "$CRUNCHY_BROKER_INSTANCES" \
  --arg crunchy_broker_persistent_disk_size "$CRUNCHY_BROKER_PERSISTENT_DISK_SIZE" \
    '
    . +
    {
      ".properties.az_multi_select": {
        "value": ($az_multi_select | split(",") | map(.))
      },
      ".properties.consul_server_vm_type": {
        "value": $consul_server_vm_type"
      },
      ".properties.consul_server_disk_type": {
        "value": $consul_server_disk_type"
      },
      ".properties.postgresql_haproxy_vm_type": {
        "value": $postgresql_haproxy_vm_type"
      },
      ".properties.postgresql_haproxy_disk_type": {
        "value": $postgresql_haproxy_disk_type"
      },
      ".properties.smoke_tests_vm_type": {
        "value": $smoke_tests_vm_type"
      },
      ".properties.smoke_tests_disk_type": {
        "value": $smoke_tests_disk_type"
      },
      ".properties.small_vm_type": {
        "value": $small_vm_type"
      },
      ".properties.small_disk_type": {
        "value": $small_disk_type"
      },
      ".properties.small_postgresql_instance_count": {
        "value": $small_postgresql_instance_count"
      },
      ".properties.small_postgresql_service_quota": {
        "value": $small_postgresql_service_quota"
      },
      ".properties.medium_vm_type": {
        "value": $medium_vm_type"
      },
      ".properties.medium_disk_type": {
        "value": $medium_disk_type"
      },
      ".properties.medium_postgresql_instance_count": {
        "value": $medium_postgresql_instance_count"
      },
      ".properties.medium_postgresql_service_quota": {
        "value": $medium_postgresql_service_quota"
      },
      ".properties.large_vm_type": {
        "value": $large_vm_type"
      },
      ".properties.large_disk_type": {
        "value": $large_disk_type"
      },
      ".properties.large_postgresql_instance_count": {
        "value": $large_postgresql_instance_count"
      },
      ".properties.large_postgresql_service_quota": {
        "value": $large_postgresql_service_quota"
      },
      ".properties.extra-large_vm_type": {
        "value": $extra-large_vm_type"
      },
      ".properties.extra-large_disk_type": {
        "value": $extra-large_disk_type"
      },
      ".properties.extra-large_postgresql_instance_count": {
        "value": $extra-large_postgresql_instance_count"
      },
      ".properties.extra-large_postgresql_service_quota": {
        "value": $extra-large_postgresql_service_quota"
      }
    }
    '
)

PRODUCT_RESOURCES=$(
  echo "{}" |
  $JQ_CMD -n \
    --arg crunchy_broker_instance_type $CRUNCHY_BROKER_INSTANCE_TYPE \
    --argjson crunchy_broker_instances $CRUNCHY_BROKER_INSTANCES \
    --argjson crunchy_broker_persistent_disk_size $CRUNCHY_BROKER_PERSISTENT_DISK_SIZE \
    '
    . +
    {
      "broker": {
        "instance_type": {"id": $crunchy_broker_instance_type},
        "instances": $crunchy_broker_instances,
        "persistent_disk_mb": $crunchy_broker_persistent_disk_size
      }
    }
    '
)

$OM_CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k configure-product -n $PRODUCT_IDENTIFIER -p "$PRODUCT_PROPERTIES" -pr "$PRODUCT_RESOURCES"
