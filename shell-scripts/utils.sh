
#!/bin/zsh
#utils use for other scripts
getInputTx() {
	BALANCE_FILE=/tmp/addressBalance.txt
	rm -f $BALANCE_FILE
	echo 'Wallet Name: ' $1
	SELECTED_WALLET_NAME=$1
	./addressBalance.sh $SELECTED_WALLET_NAME > $BALANCE_FILE
	SELECTED_WALLET_ADDR=$(cat ../wallets/$SELECTED_WALLET_NAME.addr)
	cat $BALANCE_FILE
	vared -p 'select utxo number to use as input utxo: ' -c TMP
  #get utxo row, since walletBalances has 02 header rows before utxos list so + 3, zsh start line from 1
	TX_ROW_NUM="$(($TMP+3))"
  #TX_ROW 1a8d47ed0efbdfd6df236fe4c89adbe9580b422ed0a6baf57d159141cfda7dd1     0        10000000000 lovelace + TxOutDatumNone
	TX_ROW=$(sed "${TX_ROW_NUM}q;d" $BALANCE_FILE)
  #SELECTED_UTXO 1a8d47ed0efbdfd6df236fe4c89adbe9580b422ed0a6baf57d159141cfda7dd1#0
	SELECTED_UTXO="$(echo $TX_ROW | awk '{ print $1 }')#$(echo $TX_ROW | awk '{ print $2 }')"
  #SELECTED_UTXO_LOVELACE 10000000000
	SELECTED_UTXO_LOVELACE=$(echo $TX_ROW | awk '{ print $3 }')
}

getWalletAddress() {
	WALLET_ADDRESS=$(cat ../wallets/$1.addr)
}

getDatumHash() {
	DATUM_HASH=$(cardano-cli transaction hash-script-data --script-data-value $DATUM_VALUE)
}

getScriptAddress() {
	SCRIPT_ADDRESS=$(cardano-cli address build --payment-script-file ../wallets/$1.plutus --testnet-magic $TESTNET_MAGIC_NUM)
  echo $SCRIPT_ADDRESS > ../wallets/$1.addr
}

removeTxFiles() {
  rm -f tx.raw
  rm -f tx.signed
}
