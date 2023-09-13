#!/bin/bash

while [[ $# -gt 0 ]]; do
  config_key="$1"
  case $config_key in
    -n|--network)
      network="$2"
      shift
      shift
      ;;
    -k|--conf-key)
      config_key="$2"
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$network" || -z "$config_key" ]]; then
  echo "Usage: get_chain_config.sh --network NETWORK_NAME --conf-key KEY_NAME"
  exit 1
fi

value=$(yq ".networks.$network.$config_key" l1x-conf/l1x_chain_config.yaml)

echo $value | sed 's/"//g'