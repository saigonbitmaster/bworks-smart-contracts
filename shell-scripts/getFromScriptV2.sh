#!/bin/zsh
#zsh getFromScript scriptName datumValue redeemerValue walletName
#zsh getFromScript simpleToTestScript secret.json wallet01

source ./utils.sh

SCRIPT_NAME=${1}
SCRIPT_FILE=../generated-plutus-scripts/bWorksV1/${SCRIPT_NAME}.plutus
WALLET_ADDRESS $3
TO_ADDR=$WALLET_ADDRESS
REDEEMER_FILE=$2

echo TEST $TO_ADDR

SCRIPT_ADDRESS=$($CARDANO_CLI address build --payment-script-file $SCRIPT_FILE --testnet-magic $TESTNET_MAGIC_NUM)
echo $SCRIPT_ADDRESS > ../wallets/${SCRIPT_NAME}.addr

section "Select Script UTxO"
getInputTx ${SCRIPT_NAME}
SCRIPT_UTXO=$SELECTED_UTXO
PAYMENT=$SELECTED_UTXO_LOVELACE

section "Select Collateral UTxO"
getInputTx wallet01
COLLATERAL_TX=$SELECTED_UTXO
SIGNING_WALLET=$SELECTED_WALLET_NAME
FEE_ADDR=$SELECTED_WALLET_ADDR

$CARDANO_CLI query protocol-parameters --testnet-magic $TESTNET_MAGIC_NUM > params.json

removeTxFiles

echo TEST VARIABLES
echo COLLATERAL_TX ${COLLATERAL_TX}

echo SCRIPT_UTXO ${SCRIPT_UTXO}
echo ${TO_ADDR}+${PAYMENT} 
echo ${FEE_ADDR}
echo SCRIPT_FILE $SCRIPT_FILE


$CARDANO_CLI transaction build \
--babbage-era \
--required-signer ../wallets/${SIGNING_WALLET}.skey \
--testnet-magic $TESTNET_MAGIC_NUM \
--tx-in ${SCRIPT_UTXO} \
--tx-in-script-file $SCRIPT_FILE \
--tx-in-inline-datum-present \
--tx-in-redeemer-file ${REDEEMER_FILE} \
--tx-in-collateral ${COLLATERAL_TX} \
--change-address ${TO_ADDR}+${PAYMENT} \
--protocol-params-file "params.json" \
--out-file tx.build


$CARDANO_CLI transaction sign \
--tx-body-file tx.build \
--signing-key-file ../wallets/${SIGNING_WALLET}.skey \
--testnet-magic $TESTNET_MAGIC_NUM \
--out-file tx.signed \

$CARDANO_CLI transaction submit --tx-file tx.signed --testnet-magic $TESTNET_MAGIC_NUM
