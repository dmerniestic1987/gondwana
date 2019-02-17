#!/bin/bash
export PANGEA_J_SRC_MAIN_JAVA=../pangea-j/src/main/java
web3j truffle generate --javaTypes ./build/contracts/VersusMatches.json -o $PANGEA_J_SRC_MAIN_JAVA -p com.betex.pangeaj.dao.ethereum