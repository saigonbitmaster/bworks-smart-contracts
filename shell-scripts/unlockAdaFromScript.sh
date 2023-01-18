#!/bin/zsh
#zsh unlockAdaFromScript scriptName datumValue redeemerValue walletName
#zsh unlockAdaFromScript simpleToTestScript 42 42 wallet01

source ./utils.sh

SCRIPT_NAME=${1}
SCRIPT_FILE=../generated-plutus-scripts/bWorksV1/${SCRIPT_NAME}.plutus
DATUM_VALUE=$2
getWalletAddress $4
TO_ADDR=$WALLET_ADDRESS
REDEEMER_VALUE=$3

echo TEST $TO_ADDR

DATUM_HASH=$($CARDANO_CLI transaction hash-script-data --script-data-value "$DATUM_VALUE")
SCRIPT_ADDRESS=$($CARDANO_CLI address build --payment-script-file $SCRIPT_FILE --testnet-magic $TESTNET_MAGIC_NUM)
echo $SCRIPT_ADDRESS > ../wallets/${SCRIPT_NAME}.addr

section "Select Script UTxO to unlock"
getInputTx ${SCRIPT_NAME}
SCRIPT_UTXO=$SELECTED_UTXO
PAYMENT=$SELECTED_UTXO_LOVELACE

section "Select Collateral UTxO to pay fee"
getInputTx wallet01
COLLATERAL_TX=$SELECTED_UTXO
SIGNING_WALLET=$SELECTED_WALLET_NAME
FEE_ADDR=$SELECTED_WALLET_ADDR

$CARDANO_CLI query protocol-parameters --testnet-magic $TESTNET_MAGIC_NUM > params.json

removeTxFiles

$CARDANO_CLI transaction build \
--alonzo-era \
--testnet-magic $TESTNET_MAGIC_NUM \
--change-address ${FEE_ADDR} \
--tx-in ${COLLATERAL_TX} \
--tx-in ${SCRIPT_UTXO} \
--tx-in-script-file $SCRIPT_FILE \
--tx-in-datum-value ${DATUM_VALUE} \
--tx-in-redeemer-value ${REDEEMER_VALUE} \
--tx-in-collateral ${COLLATERAL_TX} \
--tx-out ${TO_ADDR}+${PAYMENT} \
--protocol-params-file "params.json" \
--out-file tx.build

$CARDANO_CLI transaction sign \
--tx-body-file tx.build \
--signing-key-file ../wallets/${SIGNING_WALLET}.skey \
--testnet-magic $TESTNET_MAGIC_NUM \
--out-file tx.signed \

$CARDANO_CLI transaction submit --tx-file tx.signed --testnet-magic $TESTNET_MAGIC_NUM
