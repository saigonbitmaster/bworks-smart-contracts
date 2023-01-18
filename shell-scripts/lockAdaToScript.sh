#!/bin/zsh
#zsh lockAdaToScript valueInLovelace scriptName datum walletName
#zsh lockAdaToScript.sh  3000000 simpleToTestScript 42 wallet01
source ./utils.sh

getInputTx $4

FROM_ADDR=$SELECTED_WALLET_ADDR
PAYMENT=$1
SCRIPT_ADDRESS=$($CARDANO_CLI address build --payment-script-file ../generated-plutus-scripts/bWorksV1/$2.plutus --testnet-magic $TESTNET_MAGIC_NUM)
DATUM_HASH=$($CARDANO_CLI transaction hash-script-data --script-data-value "$3")
TO_ADDR=$SCRIPT_ADDRESS

echo $FROM_ADDR

$CARDANO_CLI transaction build \
--tx-in ${SELECTED_UTXO} \
--tx-out ${TO_ADDR}+${PAYMENT} \
--tx-out-datum-hash ${DATUM_HASH} \
--change-address=${FROM_ADDR} \
--testnet-magic $TESTNET_MAGIC_NUM \
--out-file tx.build \
--alonzo-era


$CARDANO_CLI transaction sign \
--tx-body-file tx.build \
--signing-key-file ../wallets/${SELECTED_WALLET_NAME}.skey \
--testnet-magic $TESTNET_MAGIC_NUM \
--out-file tx.signed \

$CARDANO_CLI transaction submit --tx-file tx.signed --testnet-magic $TESTNET_MAGIC_NUM