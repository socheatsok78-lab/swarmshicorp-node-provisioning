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
  if [[ -n "${HASHICORP_NODE_PROVISIONING_FILE_OVERRIDE}" ]]; then
    rm -f "$HASHICORP_NODE_PROVISIONING_FILE"
  else
    echo "==> Provisioning file already exists, exiting"

    source "$HASHICORP_NODE_PROVISIONING_FILE"

    test -n "$HASHICORP_NODE_ADVERTISE"       && echo "export $HASHICORP_NODE_ADVERTISE"
    test -n "$HASHICORP_NODE_ADVERTISE_WAN"   && echo "export $HASHICORP_NODE_ADVERTISE_WAN"

    exit 0
  fi
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

  HASHICORP_NODE_ADVERTISE="HASHICORP_NODE_ADVERTISE_ADDRESS=\"$HASHICORP_NODE_ADVERTISE_ADDRESS\""
  entrypoint_log "==> Found address '$HASHICORP_NODE_ADVERTISE_ADDRESS' for interface '$HASHICORP_NODE_ADVERTISE_INTERFACE', setting node advertise address..."
fi

# The advertise WAN address is used to change the address that we advertise to server nodes joining through the WAN.
if [[ -n "$HASHICORP_NODE_ADVERTISE_WAN_INTERFACE" ]]; then
  HASHICORP_NODE_ADVERTISE_WAN_ADDRESS=$(ip -o -4 addr list $HASHICORP_NODE_ADVERTISE_WAN_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$HASHICORP_NODE_ADVERTISE_WAN_ADDRESS" ]; then
    echo "Could not find IP for interface '$HASHICORP_NODE_ADVERTISE_WAN_INTERFACE', exiting"
    exit 1
  fi

  HASHICORP_NODE_ADVERTISE_WAN="HASHICORP_NODE_ADVERTISE_WAN_ADDRESS=\"$HASHICORP_NODE_ADVERTISE_WAN_ADDRESS\""
  entrypoint_log "==> Found address '$HASHICORP_NODE_ADVERTISE_WAN_ADDRESS' for interface '$HASHICORP_NODE_ADVERTISE_WAN_INTERFACE', setting node advertise-wan address..."
fi

mkdir -p $(dirname $HASHICORP_NODE_PROVISIONING_FILE)

echo "" > "$HASHICORP_NODE_PROVISIONING_FILE"
test -n "$HASHICORP_NODE_ADVERTISE"       && echo "export $HASHICORP_NODE_ADVERTISE"      | tee -a "$HASHICORP_NODE_PROVISIONING_FILE"
test -n "$HASHICORP_NODE_ADVERTISE_WAN"   && echo "export $HASHICORP_NODE_ADVERTISE_WAN"  | tee -a "$HASHICORP_NODE_PROVISIONING_FILE"

echo "==> Provisioning file written to $HASHICORP_NODE_PROVISIONING_FILE"
exit 0
