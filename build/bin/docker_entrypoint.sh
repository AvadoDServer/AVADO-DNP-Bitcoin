#!/bin/bash

set -euo pipefail

btc_prune=${BTC_PRUNE:-0}
if [ $btc_prune -ne 0 ] ; then
    BTC_TXINDEX=0
fi

BITCOIN_DIR=/root/.bitcoin
BITCOIN_CONF=${BITCOIN_DIR}/bitcoin.conf

# If config doesn't exist, initialize with sane defaults for running a
# non-mining node.

#if [ ! -e "${BITCOIN_CONF}" ]; then
tee -a >${BITCOIN_CONF} <<EOF

# For documentation on the config file, see
#
# the bitcoin source:
#   https://github.com/bitcoin/bitcoin/blob/master/contrib/debian/examples/bitcoin.conf
# the wiki:
#   https://en.bitcoin.it/wiki/Running_Bitcoin

# server=1 tells Bitcoin-Qt and bitcoind to accept JSON-RPC commands
server=1

# How many seconds bitcoin will wait for a complete RPC HTTP request.
# after the HTTP connection is established.
rpcclienttimeout=${BTC_RPCCLIENTTIMEOUT:-30}

# Allow only internal connections
rpcallowip=${BTC_RPCALLOWIP:-172.33.0.0/16}


# Print to console (stdout) so that "docker logs bitcoind" prints useful
# information.
printtoconsole=${BTC_PRINTTOCONSOLE:-1}

# We probably don't want a wallet.
disablewallet=${BTC_DISABLEWALLET:-1}

# Enable an on-disk txn index. Allows use of getrawtransaction for txns not in
# mempool.
txindex=${BTC_TXINDEX:-0}
prune=${BTC_PRUNE:-0}
testnet=${BTC_TESTNET:-0}
dbcache=${BTC_DBCACHE:-512}
zmqpubrawblock=${BTC_ZMQPUBRAWBLOCK:-tcp://0.0.0.0:28332}
zmqpubrawtx=${BTC_ZMQPUBRAWTX:-tcp://0.0.0.0:28333}
zmqpubhashtx=${BTC_ZMQPUBHASHTX:-tcp://0.0.0.0:28333}
zmqpubhashblock=${BTC_ZMQPUBHASHBLOCK:-tcp://0.0.0.0:28333}

# Options only for mainnet
[main]
# Listen for RPC connections on this TCP port:
rpcport=${BTC_RPCPORT:-8332}
# You must set rpcuser and rpcpassword to secure the JSON-RPC api
rpcbind=0.0.0.0
rpcuser=${BTC_RPCUSER:-dappnode}
rpcpassword=${BTC_RPCPASSWORD:-dappnode}

# Options only for testnet
[test]
# Listen for RPC connections on this TCP port:
rpcport=${BTC_RPCPORT:-8332}
# You must set rpcuser and rpcpassword to secure the JSON-RPC api
rpcbind=0.0.0.0
rpcuser=${BTC_RPCUSER:-dappnode}
rpcpassword=${BTC_RPCPASSWORD:-dappnode}

EOF
#fi

if [ $# -eq 0 ]; then
    cat ${BITCOIN_CONF}
    exec bitcoind -datadir=${BITCOIN_DIR} -conf=${BITCOIN_CONF}
else
    exec "$@"
fi
