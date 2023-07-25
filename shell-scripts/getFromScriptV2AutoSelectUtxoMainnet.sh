#!/bin/zsh
#this script is similar to getFromScriptV2 except it call different functions from functions.sh 
#to auto select collatel utxo & curent locked utxo (the utxo need to be unlock)
#zsh getFromScriptV2AutoSelectUtxoMainnet.sh scriptName redeemerJsonFile payCollatelWalletName receiveWalletAddress scriptTxHash
#zsh getFromScriptV2AutoSelectUtxoMainnet.sh bworksV2 secretMainnet.json wallet01Mainnet addr1v98zzr6aw4j2sl76lgqsvwtf6xkyc7pv6mlnf7quw5trc9sfy9hcf 1aa7fbc065b11cdadca3259fc48275b0c3a7ece060dfcd8c9cbbb017f91c0184 

source ./functionsMainnet.sh

SCRIPT_NAME=${1}
SCRIPT_FILE=../generated-plutus-scripts/bWorksV1/${SCRIPT_NAME}.plutus
REDEEMER_JSON_FILE=${2}
PAY_COLLATEL_WALLET=${3}
SIGNING_WALLET=${3}
RECEIVER_ADDR=${4}
SCRIPT_TXHASH=${5}
SCRIPT_ADDRESS=$(${CARDANO_CLI} address build --payment-script-file ${SCRIPT_FILE} --mainnet)
echo ${SCRIPT_ADDRESS} > ../wallets/${SCRIPT_NAME}.addr

section "Get Script UTxO"
getScriptUtxo ${SCRIPT_NAME} ${SCRIPT_TXHASH} 
SCRIPT_UTXO=${SELECTED_UTXO}
LOCKED_ASSET_VALUE=${SELECTED_UTXO_LOVELACE}

section "Select Collateral UTxO"
getCollatelUtxo ${3}
COLLATERAL_TX=${SELECTED_UTXO}

$CARDANO_CLI query protocol-parameters --mainnet > paramsMainet.json

removeTxFiles

echo TEST VARIABLES
echo SIGNING_WALLET ${SIGNING_WALLET}
echo COLLATERAL_TX ${COLLATERAL_TX}
echo RECEIVER_ADDR ${RECEIVER_ADDR}
echo SCRIPT_FILE ${SCRIPT_FILE}
echo SCRIPT_UTXO ${SCRIPT_UTXO}
echo LOCKED_ASSET_VALUE ${LOCKED_ASSET_VALUE} 


$CARDANO_CLI transaction build \
--babbage-era \
--mainnet \
--required-signer ../wallets/${SIGNING_WALLET}.skey \
--tx-in-collateral ${COLLATERAL_TX} \
--tx-in ${SCRIPT_UTXO} \
--tx-in-script-file ${SCRIPT_FILE} \
--tx-in-inline-datum-present \
--tx-in-redeemer-file ${REDEEMER_JSON_FILE} \
--change-address ${RECEIVER_ADDR} \
--protocol-params-file "paramsMainnet.json" \
--out-file tx.build


$CARDANO_CLI transaction sign \
--tx-body-file tx.build \
--signing-key-file ../wallets/${SIGNING_WALLET}.skey \
--mainnet \
--out-file tx.signed \

$CARDANO_CLI transaction submit --tx-file tx.signed --mainnet

#print txHash
TX_HASH=$($CARDANO_CLI transaction txid --tx-file tx.signed) 
DATE=$(date)
echo "Summited TxHash:" ${TX_HASH} "Date:" ${DATE}