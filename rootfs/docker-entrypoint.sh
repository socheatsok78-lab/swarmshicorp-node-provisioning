#!/bin/bash

entrypoint_log() {
    if [ -z "${HASHICORP_NODE_PROVISIONING_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

HASHICORP_NODE_PROVISIONING_DIR=${HASHICORP_NODE_PROVISIONING_DIR:-"/.swarmshicorp-node-provisioning"}
HASHICORP_NODE_PROVISIONING_FILE=${HASHICORP_NODE_PROVISIONING_FILE:-"${HASHICORP_NODE_PROVISIONING_DIR}/activate"}

echo "==> Starting HashiCorp Node Provisioning"

if [ -f "$HASHICORP_NODE_PROVISIONING_FILE" ]; then
  echo "==> Provisioning file already exists, exiting"

  source "$HASHICORP_NODE_PROVISIONING_FILE"
  test -n "$HASHICORP_NODE_ADVERTISE" && echo "- $HASHICORP_NODE_ADVERTISE"
  test -n "$HASHICORP_NODE_ADVERTISE_WAN" && echo "- $HASHICORP_NODE_ADVERTISE_WAN"
  test -n "$HASHICORP_NODE_BIND" && echo "- $HASHICORP_NODE_BIND"
  test -n "$HASHICORP_NODE_CLIENT" && echo "- $HASHICORP_NODE_CLIENT"

  exit 0
fi

# Advertise Address Options
# 
# # The advertise address is used to change the address that we advertise to other nodes in the cluster.
# By default, the -bind address is advertised.
if [[ -n "$HASHICORP_NODE_ADVERTISE_INTERFACE" ]]; then
  HASHICORP_NODE_ADVERTISE_ADDRESS=$(ip -o -4 addr list $HASHICORP_NODE_ADVERTISE_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$HASHICORP_NODE_ADVERTISE_ADDRESS" ]; then
    echo "Could not find IP for interface '$HASHICORP_NODE_ADVERTISE_INTERFACE', exiting"
    exit 1
  fi

  HASHICORP_NODE_ADVERTISE="HASHICORP_NODE_ADVERTISE_ADDRESS=$HASHICORP_NODE_ADVERTISE_ADDRESS"
  entrypoint_log "==> Found address '$HASHICORP_NODE_ADVERTISE_ADDRESS' for interface '$HASHICORP_NODE_ADVERTISE_INTERFACE', setting node advertise option..."
else
  echo "You must set HASHICORP_NODE_ADVERTISE_INTERFACE to the name of the interface you'd like to advertise, exiting"
  exit 2
fi

# The advertise WAN address is used to change the address that we advertise to server nodes joining through the WAN.
if [[ -n "$HASHICORP_NODE_ADVERTISE_WAN_INTERFACE" ]]; then
  HASHICORP_NODE_ADVERTISE_WAN_ADDRESS=$(ip -o -4 addr list $HASHICORP_NODE_ADVERTISE_WAN_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$HASHICORP_NODE_ADVERTISE_WAN_ADDRESS" ]; then
    echo "Could not find IP for interface '$HASHICORP_NODE_ADVERTISE_WAN_INTERFACE', exiting"
    exit 1
  fi

  HASHICORP_NODE_ADVERTISE_WAN="HASHICORP_NODE_ADVERTISE_WAN_ADDRESS-wan=$HASHICORP_NODE_ADVERTISE_WAN_ADDRESS"
  entrypoint_log "==> Found address '$HASHICORP_NODE_ADVERTISE_WAN_ADDRESS' for interface '$HASHICORP_NODE_ADVERTISE_WAN_INTERFACE', setting node advertise-wan option..."
else
  echo "You must set HASHICORP_NODE_ADVERTISE_WAN_INTERFACE to the name of the interface you'd like to advertise-wan, exiting"
  exit 2
fi

# You can set HASHICORP_NODE_BIND_INTERFACE to the name of the interface you'd like to
# bind to and this will look up the IP and pass the proper -bind= option along
# to Consul.
if [ -n "$HASHICORP_NODE_BIND_INTERFACE" ]; then
  HASHICORP_NODE_BIND_ADDRESS=$(ip -o -4 addr list $HASHICORP_NODE_BIND_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$HASHICORP_NODE_BIND_ADDRESS" ]; then
    echo "Could not find IP for interface '$HASHICORP_NODE_BIND_INTERFACE', exiting"
    exit 1
  fi

  HASHICORP_NODE_BIND="HASHICORP_NODE_BIND_ADDRESS=$HASHICORP_NODE_BIND_ADDRESS"
  echo "==> Found address '$HASHICORP_NODE_BIND_ADDRESS' for interface '$HASHICORP_NODE_BIND_INTERFACE', setting node bind option..."
fi

# You can set HASHICORP_NODE_CLIENT_INTERFACE to the name of the interface you'd like to
# bind client intefaces (HTTP, DNS, and RPC) to and this will look up the IP and
# pass the proper -client= option along to Consul.
if [ -n "$HASHICORP_NODE_CLIENT_INTERFACE" ]; then
  HASHICORP_NODE_CLIENT_ADDRESS=$(ip -o -4 addr list $HASHICORP_NODE_CLIENT_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$HASHICORP_NODE_CLIENT_ADDRESS" ]; then
    echo "Could not find IP for interface '$HASHICORP_NODE_CLIENT_INTERFACE', exiting"
    exit 1
  fi

  HASHICORP_NODE_CLIENT="HASHICORP_NODE_CLIENT_ADDRESS=$HASHICORP_NODE_CLIENT_ADDRESS"
  echo "==> Found address '$HASHICORP_NODE_CLIENT_ADDRESS' for interface '$HASHICORP_NODE_CLIENT_INTERFACE', setting node client option..."
fi


mkdir -p $(dirname $HASHICORP_NODE_PROVISIONING_FILE)
cat <<EOT > "$HASHICORP_NODE_PROVISIONING_FILE"
export $HASHICORP_NODE_ADVERTISE
export $HASHICORP_NODE_ADVERTISE_WAN
export $HASHICORP_NODE_BIND
export $HASHICORP_NODE_CLIENT
EOT

test -n "$HASHICORP_NODE_ADVERTISE" && echo "- $HASHICORP_NODE_ADVERTISE"
test -n "$HASHICORP_NODE_ADVERTISE_WAN" && echo "- $HASHICORP_NODE_ADVERTISE_WAN"
test -n "$HASHICORP_NODE_BIND" && echo "- $HASHICORP_NODE_BIND"
test -n "$HASHICORP_NODE_CLIENT" && echo "- $HASHICORP_NODE_CLIENT"

echo "==> Provisioning file written to $HASHICORP_NODE_PROVISIONING_FILE"
exit 0
