#!/bin/bash

# This script is a tool interface for l1x tools.
# It takes an action and a contract name as input,
# and executes the corresponding command.

# The action can be one of the following:
# gen-ir: Generate LLVM IR from a WASM contract.
# gen-bpf: Generate BPF program from a LLVM IR contract.
# sub-txn: Submit a transaction.

# The contract name is the name of the WASM contract file.

# Import environment settings from drt_node_env.sh
source /home/l1x/l1x-ws/l1x-conf/drt_node_env.sh

# Get the action and contract name from the command line arguments.
action=$1
contract_name=$2

# Add `--help` command
if [[ "$1" == "--help" ]]; then
  echo "Usage: $0 <action> [options]"
  echo "Available actions:"
  echo "  gen-ir: Generate LLVM IR from a WASM contract."
  echo "  gen-bpf: Generate BPF program from a LLVM IR contract."
  echo "  sub-txn: Submit a transaction."
  echo "  get-chain-state: Get the Chain State."
  echo "  start-devnode: Start Node Server."
  echo "Options:"
  echo "  --rpc: The JSON RPC endpoint."
  echo "  --owner: The account address of the transaction sender."
  echo "  --payload: The path to the transaction payload file."
  exit 0
fi

# Check the validity of the action.
if [ "$action" != "gen-ir" ] && [ "$action" != "gen-bpf" ] && [ "$action" != "sub-txn" ] && [ "$action" != "read-only-func-call" ] && [ "$action" != "get-acc-state" ] && [ "$action" != "get-chain-state" ] &&[ "$action" != "start-devnode" ] && [ "$action" != "sub-sol" ] && [ "$action" != "get-deployed-address" ] && [ "$action" != "launch-event-handler" ]; then
  echo "Invalid action: $action"
  # Loop through all the arguments and print each one
  echo "Passed Arguments ..."
  for arg in "$@"; do
    echo "  Argument: $arg"
  done

  exit 1
fi

# Directory where the artifacts are located
artifacts_dir="/home/l1x/l1x-ws/l1x-artifacts"

# Handle different commands
case "$action" in
    launch-event-handler)
        echo "Trace Inside DRT $(uname) :: launch-event-handler"
        echo "Trace Inside DRT $(uname) :: EVENT_HANDLER_TYPE :: $2"

        # Evn Configurations
        echo "Trace Inside DRT $(uname) :: L1X_JSON_PORT :: $L1X_JSON_PORT"
        echo "Trace Inside DRT $(uname) :: L1X_PROTO_PORT :: $L1X_PROTO_PORT"
        echo "Trace Inside DRT $(uname) :: L1X_ENDPOINT :: $L1X_ENDPOINT"
        echo "Trace Inside DRT $(uname) :: CLI_ARCH :: $CLI_ARCH"
        echo "Trace Inside DRT $(uname) :: INTF_ARG_REGISTRY_CONTRACT_ADDRESS :: $INTF_ARG_REGISTRY_CONTRACT_ADDRESS"

        RUST_LOG=debug REGISTRY_CONTRACT_ADDRESS=$INTF_ARG_REGISTRY_CONTRACT_ADDRESS listener_node $2
        ;;
    gen-ir)
        echo "Trace Inside DRT $(uname) :: gen-ir"
        echo "Trace Inside DRT $(uname) :: INTF_ARG_CONTRACT :: $INTF_ARG_CONTRACT"
        contract_file="$artifacts_dir/$INTF_ARG_CONTRACT.wasm"
        echo "Trace Inside DRT $(uname) :: CONTRACT_PATH :: $contract_file"

        # Check the existence of the contract file.
        if [ ! -f "$contract_file" ]; then
        echo "Contract file not found: $contract_file"
        exit 1
        fi
        wasm-llvmir "$contract_file"
        ;;
    gen-bpf)
        echo "Trace Inside DRT $(uname) :: gen-bpf"
        echo "Trace Inside DRT $(uname) :: INTF_ARG_CONTRACT :: $INTF_ARG_CONTRACT"
        contract_file="$artifacts_dir/$INTF_ARG_CONTRACT.ll"
        echo "Trace Inside DRT $(uname) :: CONTRACT_PATH :: $contract_file"

        # Check the existence of the contract file.
        if [ ! -f "$contract_file" ]; then
        echo "Contract file not found: $contract_file"
        exit 1
        fi
        build_ebpf.sh "$contract_file"
        ;;
    sub-txn)
        echo "Trace Inside DRT $(uname) :: sub-txn"
        echo "Trace Inside DRT $(uname) :: L1X_CFG_CHAIN_TYPE :: $L1X_CFG_CHAIN_TYPE"
        NODE_JSON_RPC=$(yq ".networks.$L1X_CFG_CHAIN_TYPE.rpc_endpoint" l1x-ws/l1x-conf/l1x_chain_config.yaml)
        echo "Trace Inside DRT $(uname) :: NODE_JSON_RPC :: $NODE_JSON_RPC"

        echo "Trace Inside DRT $(uname) :: INTF_ARG_OWNER :: $INTF_ARG_OWNER"
        PRIV_KEY=$(yq ".dev_accounts.$INTF_ARG_OWNER.priv" l1x-ws/l1x-conf/l1x_dev_wallets.yaml)
        echo "Trace Inside DRT $(uname) :: PRIV_KEY :: $PRIV_KEY"

        echo "Trace Inside DRT $(uname) :: INTF_ARG_PAYLOAD :: $INTF_ARG_PAYLOAD"
        PAYLOAD_PATH="/home/l1x/l1x-ws/l1x-conf/scripts/$INTF_ARG_PAYLOAD"
        echo "Trace Inside DRT $(uname) :: PAYLOAD_PATH :: $PAYLOAD_PATH"

        # Check if required options are provided
        if [ -z "$NODE_JSON_RPC" ] || [ -z "$PRIV_KEY" ] || [ -z "$PAYLOAD_PATH" ]; then
            echo "Usage: $0 sub-txn --rpc <JSON_RPC> --owner <ACC_SUPER> --payload <payload_file>"
            exit 1
        fi

        # Check the existence of the contract file.
        if [ ! -f "$PAYLOAD_PATH" ]; then
            echo "Payload file not found: $PAYLOAD_PATH"
            exit 1
        fi

        echo "cli invoked with options::"
        echo "   --endpoint :: $NODE_JSON_RPC"
        echo "   --private-key :: $PRIV_KEY"
        echo "   --payload-file-path :: $PAYLOAD_PATH"

		echo "   cli path :: $(which cli)"

        # execution
        l1x_deployment_txn_output=$(RUST_LOG=info cli --endpoint $NODE_JSON_RPC --private-key $PRIV_KEY submit-txn --payload-file-path $PAYLOAD_PATH)

		echo "L1x Deployment Txn response :: $l1x_deployment_txn_output"
        ;;
    read-only-func-call)
        echo "Trace Inside DRT $(uname) :: read-only-func-call"
        echo "Trace Inside DRT $(uname) :: L1X_CFG_CHAIN_TYPE :: $L1X_CFG_CHAIN_TYPE"
        NODE_JSON_RPC=$(yq ".networks.$L1X_CFG_CHAIN_TYPE.rpc_endpoint" l1x-ws/l1x-conf/l1x_chain_config.yaml)
        echo "Trace Inside DRT $(uname) :: NODE_JSON_RPC :: $NODE_JSON_RPC"

        echo "Trace Inside DRT $(uname) :: INTF_ARG_OWNER :: $INTF_ARG_OWNER"
        PRIV_KEY=$(yq ".dev_accounts.$INTF_ARG_OWNER.priv" l1x-ws/l1x-conf/l1x_dev_wallets.yaml)
        echo "Trace Inside DRT $(uname) :: PRIV_KEY :: $PRIV_KEY"

        echo "Trace Inside DRT $(uname) :: INTF_ARG_PAYLOAD :: $INTF_ARG_PAYLOAD"
        PAYLOAD_PATH="/home/l1x/l1x-ws/l1x-conf/scripts/$INTF_ARG_PAYLOAD"
        echo "Trace Inside DRT $(uname) :: PAYLOAD_PATH :: $PAYLOAD_PATH"

        # Check if required options are provided
        if [ -z "$NODE_JSON_RPC" ] || [ -z "$PRIV_KEY" ] || [ -z "$PAYLOAD_PATH" ]; then
            echo "Usage: $0 sub-txn --rpc <JSON_RPC> --owner <ACC_SUPER> --payload <payload_file>"
            exit 1
        fi

        echo "cli invoked with options::"
        echo "   --endpoint :: $NODE_JSON_RPC"
        echo "   --private-key :: $PRIV_KEY"
        echo "   --payload-file-path :: $PAYLOAD_PATH"

        # execution
        RUST_LOG=info cli --endpoint $NODE_JSON_RPC --private-key $PRIV_KEY read-only-func-call --payload-file-path $PAYLOAD_PATH
        ;;
    sub-sol)
        echo "Trace Inside DRT $(uname) :: sub-txn"
        echo "Trace Inside DRT $(uname) :: L1X_CFG_CHAIN_TYPE :: $L1X_CFG_CHAIN_TYPE"
        NODE_JSON_RPC=$(yq ".networks.$L1X_CFG_CHAIN_TYPE.rpc_endpoint" l1x-ws/l1x-conf/l1x_chain_config.yaml)
        echo "Trace Inside DRT $(uname) :: NODE_JSON_RPC :: $NODE_JSON_RPC"

        echo "Trace Inside DRT $(uname) :: INTF_ARG_OWNER :: $INTF_ARG_OWNER"
        PRIV_KEY=$(yq ".dev_accounts.$INTF_ARG_OWNER.priv" l1x-ws/l1x-conf/l1x_dev_wallets.yaml)
        echo "Trace Inside DRT $(uname) :: PRIV_KEY :: $PRIV_KEY"

        echo "Trace Inside DRT $(uname) :: INTF_ARG_PAYLOAD :: $INTF_ARG_PAYLOAD"
        PAYLOAD_PATH="/home/l1x/l1x-ws/l1x-conf/scripts/$INTF_ARG_PAYLOAD"
        echo "Trace Inside DRT $(uname) :: PAYLOAD_PATH :: $PAYLOAD_PATH"

        # Check if required options are provided
        if [ -z "$NODE_JSON_RPC" ] || [ -z "$PRIV_KEY" ] || [ -z "$PAYLOAD_PATH" ]; then
            echo "Usage: $0 sub-sol --rpc <JSON_RPC> --owner <ACC_SUPER> --payload <payload_file>"
            exit 1
        fi

        echo "cli invoked with options::"
        echo "   --endpoint :: $NODE_JSON_RPC"
        echo "   --private-key :: $PRIV_KEY"
        echo "   --payload-file-path :: $PAYLOAD_PATH"

        # Step-01: Execute "submit-sol" command and store the txn_hash in a variable
        eth_deployment_txn_output=$(RUST_LOG=info cli --endpoint $NODE_JSON_RPC --private-key $PRIV_KEY submit-sol --payload-file-path $PAYLOAD_PATH)

        echo "Eth Deplyment Txn response :: $eth_deployment_txn_output"
        txn_hash=$(echo "$eth_deployment_txn_output" | grep -o 'hash: "[^"]*' | awk -F'"' '{print $2}')

        echo "Eth Deplyment Txn Hash :: $txn_hash"

        sleep 5

        # Step-02: Use txn_hash from Step-01 in "get-events" and deserialize events_data
        eth_get_events_response=$(RUST_LOG=info cli --endpoint $NODE_JSON_RPC --private-key $PRIV_KEY get-events --tx-hash $txn_hash)

        echo "Eth Get Event Response :: $eth_get_events_response"

        events_data=$(echo "$eth_get_events_response" | jq -r '.events_data' )

        # events_data="$(echo "$eth_get_events_response" | grep -o 'events_data: \[[0-9, ]*\]' | sed 's/events_data: \[//')"

        echo "Eth Get Event :: $events_data"

        # # Convert events_data from comma-separated bytes to an array
        # IFS=', ' read -r -a bytes_array <<< "$events_data"

        # # Loop through the bytes array and convert each element to a string
        # event_strings=()
        # for bytes in "${bytes_array[@]}"; do
        # event_strings+=("$(echo "$bytes" | tr ',' '\n' | xargs -I{} printf "\\x{}")")
        # done

        # # Print the deserialized event strings
        # for event_string in "${event_strings[@]}"; do
        # echo "Deserialized Event: $event_string"
        # done
        ;;
    get-acc-state)
        # Get Chain State
        echo "Trace Inside DRT $(uname) :: Get Account State"
        echo "Trace Inside DRT $(uname) :: L1X_CHAIN_TYPE :: $L1X_CFG_CHAIN_TYPE"
        NODE_JSON_RPC=$(yq ".networks.$L1X_CFG_CHAIN_TYPE.rpc_endpoint" l1x-ws/l1x-conf/l1x_chain_config.yaml)
        echo "Trace Inside DRT $(uname) :: NODE_JSON_RPC :: $NODE_JSON_RPC"

        echo "Trace Inside DRT $(uname) :: INTF_ARG_OWNER :: $INTF_ARG_OWNER"
        PRIV_KEY=$(yq ".dev_accounts.$INTF_ARG_OWNER.priv" l1x-ws/l1x-conf/l1x_dev_wallets.yaml)
        echo "Trace Inside DRT $(uname) :: PRIV_KEY :: $PRIV_KEY"

        RUST_LOG=info cli --endpoint $NODE_JSON_RPC --private-key $PRIV_KEY account-state
        ;;
    get-chain-state)
        # Get Chain State
        echo "Trace Inside DRT $(uname) :: Get Chain State"
        echo "Trace Inside DRT $(uname) :: L1X_CHAIN_TYPE :: $L1X_CFG_CHAIN_TYPE"
        NODE_JSON_RPC=$(yq ".networks.$L1X_CFG_CHAIN_TYPE.rpc_endpoint" l1x-ws/l1x-conf/l1x_chain_config.yaml)
        echo "Trace Inside DRT $(uname) :: NODE_JSON_RPC :: $NODE_JSON_RPC"
        RUST_LOG=info cli --endpoint $NODE_JSON_RPC chain-state
        ;;
    start-devnode)
        # Launch the server in Dev mode
        echo "Trace Inside DRT $(uname) :: Launch the server in Dev mode::"
        echo "Trace Inside DRT $(uname) :: CASSANDRA_HOST :: $CASSANDRA_HOST"
        echo "Trace Inside DRT $(uname) :: CASSANDRA_PORT :: $CASSANDRA_PORT"
        RUST_LOG=info server --dev
        ;;
    get-deployed-address)
        # Get Last Deployed Address
        echo "Trace Inside DRT $(uname) :: Get Last Deployed Address::"

        # Get the name of the trace log file
        log_file="/home/l1x/l1x-ws/devbox-services.log"
        echo "Trace Inside DRT $(uname) :: From Trace File :: $log_file"

        # Create a temporary file to store the last 100 lines of the trace log file
        temp_file_01=$(mktemp)

        # Tail the trace log file and store the last 100 lines in the temporary file
        tail -n 500 "${log_file}" > "${temp_file_01}"

        # Reverse the lines in the temporary file
        tac "${temp_file_01}" | while IFS= read -r line; do
            # Check if the line contains the search tag
            if [[ "$line" == *"EXECUTING EVM CONTRACT DEPLOYMENT"* ]]; then

                # Extract the deployment address from the line
                deployment_address=$(echo "${line}" | awk '{print $NF}')

                # Print the result
                echo "Deployment address :: $deployment_address"

                # Exit the loop
                break
            fi
        done

        # Clean up: Remove the temporary file
        rm "$temp_file_01"
        ;;
    *)
        echo "Unknown command: $action"
        exit 1
        ;;
esac

# Exit successfully
exit 0
