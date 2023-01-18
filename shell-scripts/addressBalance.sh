#!/bin/zsh
#run script: zsh addressBalance.sh walletName/scriptName
#walletName is fileName of a wallet in wallets folder e.g wallet01
#the command to query contract & wallet address is the same
#./addressBalance.sh unlockByBWorksWithDeadLineScript
#./addressBalance.sh wallet01
$CARDANO_CLI query utxo --address $(cat ../wallets/$1.addr) --testnet-magic $TESTNET_MAGIC