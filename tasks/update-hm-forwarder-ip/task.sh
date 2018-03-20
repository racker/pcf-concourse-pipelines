#!/bin/bash -ex

chmod +x om-cli/om-linux
CMD=./om-cli/om-linux

HM_GUID=`$CMD -t https://$OPS_MGR_HOST -k -u $OPS_MGR_USR -p $OPS_MGR_PWD curl -p "/api/v0/deployed/products" -x GET | jq '.[] | select(.type | contains("bosh-hm-forwarder")) | .installation_name' | tr -d '"'`

HM_MANIFEST=`$CMD -t https://$OPS_MGR_HOST -k -u $OPS_MGR_USR -p $OPS_MGR_PWD curl -p "/api/v0/staged/products/$HM_GUID/manifest" -x GET`
HM_IP=`echo $HM_MANIFEST | jq -r .manifest.instance_groups[0].networks[0].static_ips[0]`

DIRECTOR_CONFIG=$(cat <<-EOF
{
  "opentsdb_ip": "$HM_IP"
}
EOF
)

$CMD -t https://$OPS_MGR_HOST -k -u $OPS_MGR_USR -p $OPS_MGR_PWD configure-bosh \
            -d "$DIRECTOR_CONFIG"
