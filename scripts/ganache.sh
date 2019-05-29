#!/usr/bin/env bash
NODE_DIR="${HOME}/nodo-dir/betex-gondwana/"
GANACHE_PORT=8545

# Exit script as soon as a command fails.
set -o errexit

# Executes cleanup function at script exit.
trap cleanup EXIT

cleanup() {
  # Kill the ganache instance that we started (if we started one and if it's still running).
  if [ -n "$ganache_pid" ] && ps -p $ganache_pid > /dev/null; then
    kill -9 $ganache_pid
  fi
}

ganache_running() {
  nc -z localhost "$GANACHE_PORT"
}

start_ganache() {
  # We define 10 accounts with balance 1M ether, needed for high-value tests.
  local accounts=(
    --account="0xfe5601c6f9b9f1078eb89a25c93aa6bf2b32f1448cd773dff612ca1fd849ba5f,10000000000000000000000000"
    --account="0x0bb2c49af2be2223fc3f4fe019abd56769733775a2ff4ed9b927ffa201bcf6c9,1000000000000000000000000"
    --account="0x405cc1eb7617b91a30de3ee1e39e128c6c426cf5e4d725e8c0a2a4da114bba18,1000000000000000000000000"
    --account="0xb866efca7a7eed2f6a05b3cbb21069cb6b5dfe627f75fcbe257b2c6b431baa7a,1000000000000000000000000"
    --account="0xfc32eae777e356be3f74cfe02f640b70d3256125674b441e82e06521a7075130,1000000000000000000000000"
    --account="0xb20fa0e97005d5f3cb75353f8c796fc15dc4ab87d5cb03fddd2f0a6e74339899,1000000000000000000000000"
    --account="0xd33dde1f264dfbe3c547fb8915351026ba71fff940036853e19361294dbc2c57,1000000000000000000000000"
    --account="0x9f779b793dcd69b44a7107f03222c9e44c5dd9eef5ac8244adb7994328a4a0b5,1000000000000000000000000"
    --account="0xfe2b928e0b38589460857423fd0629300dac80ff39f18809dd13df3504f930d9,1000000000000000000000000"
    --account="0xcb91ec5c3f694e378de61f3a607a524924a2f6d442b4c7518b4d6d26ca788788,1000000000000000000000000"
  )
  if [ ! -d "$NODE_DIR" ]; then
    mkdir -p "$NODE_DIR"
  fi

  node_modules/.bin/ganache-cli --db "$NODE_DIR" --gasLimit 0xfffffffffff "${accounts[@]}"

  ganache_pid=$!
}

if ganache_running; then
  echo "* * * * USING EXISTING GANACHE INSTANCE * * * *"
else
  echo "* * * * STARTING NEW GANACHE INSTANCE * * * *"
  start_ganache
fi

truffle version