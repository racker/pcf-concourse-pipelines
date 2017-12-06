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
    '. +
    {
      "singleton_availability_zone": {
        "name": $singleton_jobs_az
      },
      "other_availability_zones": ($other_azs | split(",") | map({name: .})),
      "network": {
        "name": $network_name
      }
    }
    '
)

$OM_CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k configure-product -n $PRODUCT_IDENTIFIER -pn "$PRODUCT_NETWORK_CONFIG"

PRODUCT_PROPERTIES=$(
  echo "{}" |
      $JQ_CMD -n \
      --argjson bosh_ssh_enabled $BOSH_SSH_ENABLED \
      --arg windows_admin_password "$WINDOWS_ADMIN_PASSWORD" \
      --arg windows_admin_password_set_password_password "$WINDOWS_ADMIN_PASSWORD_SET_PASSWORD_PASSWORD" \
      --arg system_logging "$SYSTEM_LOGGING" \
      --arg system_logging_enable_syslog_host "$SYSTEM_LOGGING_ENABLE_SYSLOG_HOST" \
      --arg system_logging_enable_syslog_port "$SYSTEM_LOGGING_ENABLE_SYSLOG_PORT" \
      --arg system_logging_enable_syslog_protocol "$SYSTEM_LOGGING_ENABLE_SYSLOG_PROTOCOL" \
      --arg windows_diego_cell_placement_tags "$WINDOWS_DIEGO_CELL_PLACEMENT_TAGS" \
    '
    . +
    {
      ".properties.bosh_ssh_enabled": {
        "value": $bosh_ssh_enabled
      },
      ".properties.windows_admin_password": {
        "value": $windows_admin_password
      }
    }
    +
    if $windows_admin_password == "set_password" then
    {
     ".properties.windows_admin_password_set_password.password": {
        "value": $windows_admin_password_set_password_password
      }
    }
    else .
    end
    +
    {
      ".properties.system_logging": {
        "value": $system_logging
      }
    }
    +
    if $system_logging == "enabled" then
    {
      ".properties.system_logging.enable.syslog_host": {
        "value": $system_logging_enable_syslog_host
      },
      ".properties.system_logging.enable.syslog_port": {
        "value": $system_logging_enable_syslog_port
      },
      ".properties.system_logging.enable.syslog_protocol": {
        "value": $system_logging_enable_syslog_protocol
      }
    }
    else .
    end
    +
    if $windows_diego_cell_placement_tags == "null" then
    {
      ".properties.windows_diego_cell.placement_tags": {
        "value": ""
      }
    }
    else
    {
      ".properties.windows_diego_cell.placement_tags": {
        "value": "$windows_diego_cell_placement_tags"
      }
    }
    end
    '
)

PRODUCT_RESOURCES=$(
  echo "{}" |
  $JQ_CMD -n \
    --arg diego_cell_instance_type $DIEGO_CELL_INSTANCE_TYPE \
    --argjson diego_cell_instances $DIEGO_CELL_INSTANCES \
    --arg hwc_errand_instance_type $HWC_ERRAND_INSTANCE_TYPE \
    '
    . +
    {
      "windows_diego_cell": {
        "instance_type": {"id": $diego_cell_instance_type},
        "instances": $diego_cell_instances
      },
      "install-hwc-buildpack": {
        "instance_type": {"id": $hwc_errand_instance_type}
      }
    }
    '
)

$OM_CMD -t https://$OPS_MGR_HOST -u $OPS_MGR_USR -p $OPS_MGR_PWD -k configure-product -n $PRODUCT_IDENTIFIER -p "$PRODUCT_PROPERTIES" -pr "$PRODUCT_RESOURCES"
