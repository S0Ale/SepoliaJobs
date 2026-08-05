#!/bin/sh

while [[ $# -gt 0 ]]; do
  case $1 in
    --addr)
        ADDR="$2"
        shift
        shift
        ;;
    --op)
        OP="$2"
        shift
        shift
        ;;
    --id)
        ID="$2"
        shift
        shift
        ;;
  esac
done

if [ -z "$OP" ]; then
    echo "Please specify an operation to be executed"
    exit 1
fi

if [ -z "$ID" ]; then
    ID=1
fi

OP=$OP ID=$ID ADDR=$ADDR npx hardhat run scripts/contract_op.js --network localhost
