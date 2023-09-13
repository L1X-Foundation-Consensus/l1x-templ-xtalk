#!/bin/bash

while [[ $# -gt 0 ]]; do
  config_key="$1"
  case $config_key in
    -d|--dev)
      dev="$2"
      shift
      shift
      ;;
    -t|--type)
      key_type="$2"
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$dev" || -z "$key_type" ]]; then
  echo "Usage: get_dev_address.sh --dev ava --type pub"
  exit 1
fi

value=$(yq ".dev_accounts.$dev.$key_type" l1x-conf/l1x_dev_wallets.yaml)

echo $value | sed 's/"//g'