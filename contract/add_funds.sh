#!/bin/sh

ADDR=$1 npx hardhat run scripts/add_funds.js --build-profile production --network localhost
