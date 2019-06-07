#!/bin/bash
export PANGEA_J_SRC_MAIN_JAVA=../pangea-j/src/main/java
export PANGEA_J_SC_PACKAGE=com.betex.pangeaj.dao.ethereum
export BETEX_MOBILE_ANDROID_OUTPUT=./build/android/
export BETEX_MOBILE_SC_PACKAGE=ar.com.betex.betexmobile.blockchain.sc

echo "*** GENERANDO CLASES JAVA DE SC ***"
rm -Rf $BETEX_MOBILE_ANDROID_OUTPUT
mkdir $BETEX_MOBILE_ANDROID_OUTPUT
#= = = = = pangea-j = = = = =
web3j truffle generate --javaTypes ./build/contracts/VersusMatches.json -o $PANGEA_J_SRC_MAIN_JAVA -p $PANGEA_J_SC_PACKAGE
web3j truffle generate --javaTypes ./build/contracts/BetexCore.json -o $PANGEA_J_SRC_MAIN_JAVA -p $PANGEA_J_SC_PACKAGE
#= = = = = betex-mobile = = = = =
web3j truffle generate --javaTypes ./build/contracts/VersusMatches.json -o $BETEX_MOBILE_ANDROID_OUTPUT -p $BETEX_MOBILE_SC_PACKAGE
web3j truffle generate --javaTypes ./build/contracts/BetexCore.json -o $BETEX_MOBILE_ANDROID_OUTPUT -p $BETEX_MOBILE_SC_PACKAGE