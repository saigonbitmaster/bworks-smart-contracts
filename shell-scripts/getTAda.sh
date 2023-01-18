#!/bin/zsh
#run script: zsh getTAda.sh walletName keyValue
#walletName is fileName of a wallet in wallets folder e.g wallet01
#keyValue is optional
WALLETNAME=$1
ADDRESS=$(cat ./wallets/${WALLETNAME}.addr)
KEY=$2
curl "https://faucet.preprod.world.dev.cardano.org/send-money?${ADDRESS}&apiKey=${KEY}"