#!/usr/bin/env bash
export BETEX_PANGEA_JAVA_OUTPUT=./build/java/
export BETEX_BLOCKCHAIN_PACKAGE=ar.com.betex.blockchain.sc

echo "*** OUTPUT JAVA: $BETEX_PANGEA_JAVA_OUTPUT ***"
rm -Rf $BETEX_PANGEA_JAVA_OUTPUT
mkdir $BETEX_PANGEA_JAVA_OUTPUT

echo "*** Generando clases para PANGEA Package: $BETEX_BLOCKCHAIN_PACKAGE ***"
web3j truffle generate --javaTypes ./build/contracts/VersusMatches.json -o $BETEX_PANGEA_JAVA_OUTPUT -p $BETEX_BLOCKCHAIN_PACKAGE
web3j truffle generate --javaTypes ./build/contracts/BetexCore.json -o $BETEX_PANGEA_JAVA_OUTPUT -p $BETEX_BLOCKCHAIN_PACKAGE
web3j truffle generate --javaTypes ./build/contracts/BetexExchange.json -o $BETEX_PANGEA_JAVA_OUTPUT -p $BETEX_BLOCKCHAIN_PACKAGE
web3j truffle generate --javaTypes ./build/contracts/BetexToken.json -o $BETEX_PANGEA_JAVA_OUTPUT -p $BETEX_BLOCKCHAIN_PACKAGE
web3j truffle generate --javaTypes ./build/contracts/BetexSettings.json -o $BETEX_PANGEA_JAVA_OUTPUT -p $BETEX_BLOCKCHAIN_PACKAGE