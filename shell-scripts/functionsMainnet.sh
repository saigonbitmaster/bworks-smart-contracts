#given a wallet or script name, prompt user select an utxo to use in lock/unlock transaction
getInputTx() {
	BALANCE_FILE=/tmp/walletBalances.txt
	rm -f $BALANCE_FILE
	echo 'Wallet Name: ' $1
	SELECTED_WALLET_NAME=$1
	./balanceMainnet.sh $SELECTED_WALLET_NAME > $BALANCE_FILE
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


getInputTxAuto() {
	echo 'paying fee wallet name: ' $1
	SELECTED_WALLET_NAME=$1
	TX_ROW=$(./balanceMainnet.sh $SELECTED_WALLET_NAME | sort -k3,3rn | head -n 1)
	SELECTED_WALLET_ADDR=$(cat ../wallets/$SELECTED_WALLET_NAME.addr)
  #SELECTED_UTXO 1a8d47ed0efbdfd6df236fe4c89adbe9580b422ed0a6baf57d159141cfda7dd1#0
	SELECTED_UTXO="$(echo $TX_ROW | awk '{ print $1 }')#$(echo $TX_ROW | awk '{ print $2 }')"
  #SELECTED_UTXO_LOVELACE 10000000000
	SELECTED_UTXO_LOVELACE=$(echo $TX_ROW | awk '{ print $3 }')
}


#getCollatelUtxo "wallet01"
#return: SELECTED_UTXO: 4f1599342c4db12fb84dbb5c0b7f47fa676cdc49c5500047e1a59b835b0d9c29#1 SELECTED_UTXO_LOVELACE: 8938835991
#given wallet name return utxo with max lovelace value to use as collatel UTXO.
#this use for unlock transaction to make sure it has enough ada to pay the fee.
getCollatelUtxo() {
	echo 'paying fee wallet name: ' $1
	SELECTED_WALLET_NAME=$1
	TX_ROW=$(./balanceMainnet.sh $SELECTED_WALLET_NAME | sort -k3,3rn | head -n 1)
	SELECTED_WALLET_ADDR=$(cat ../wallets/$SELECTED_WALLET_NAME.addr)
  #SELECTED_UTXO 1a8d47ed0efbdfd6df236fe4c89adbe9580b422ed0a6baf57d159141cfda7dd1#0
	SELECTED_UTXO="$(echo $TX_ROW | awk '{ print $1; exit }')#$(echo $TX_ROW | awk '{ print $2; exit }')"
  #SELECTED_UTXO_LOVELACE 10000000000
	SELECTED_UTXO_LOVELACE=$(echo $TX_ROW | awk '{ print $3; exit }')
}


#getScriptUtxo bwroksV2 "fcc481e2c9babfc863472604965b492596fbfaf1b3e046e704a7f82e55c0a579"
#SELECTED_UTXO: fcc481e2c9babfc863472604965b492596fbfaf1b3e046e704a7f82e55c0a579#0 
#SELECTED_UTXO_LOVELACE: 5000000
#given script name & txHash return script utxo and asset value of that utxo
getScriptUtxo() {
	echo 'plutus script name: ' $1
	echo 'script txHash: ' $2
	SELECTED_PLUTUS_SCRIPT=$1
	SELECTED_WALLET_ADDR=$(cat ../wallets/$SELECTED_PLUTUS_SCRIPT.addr)
	TX_ROW=$(./balanceMainnet.sh $SELECTED_PLUTUS_SCRIPT | grep ${2})
  #TX_ROW 1a8d47ed0efbdfd6df236fe4c89adbe9580b422ed0a6baf57d159141cfda7dd1     0        10000000000 lovelace + TxOutDatumNone
  #SELECTED_UTXO 1a8d47ed0efbdfd6df236fe4c89adbe9580b422ed0a6baf57d159141cfda7dd1#0
	SELECTED_UTXO="$(echo $TX_ROW | awk '{ print $1; exit }')#$(echo $TX_ROW | awk '{ print $2; exit }')"
  #SELECTED_UTXO_LOVELACE 10000000000
	SELECTED_UTXO_LOVELACE=$(echo $TX_ROW | awk '{ print $3; exit }')
}


walletAddress() {
	WALLET_ADDRESS=$(cat ../wallets/$1.addr)
}

setDatumHash() {
	DATUM_HASH=$(cardano-cli transaction hash-script-data --script-data-value $DATUM_VALUE)
}

getScriptAddress() {
	SCRIPT_ADDRESS=$(cardano-cli address build --payment-script-file ../wallets/$1.plutus --mainnet)
  echo $SCRIPT_ADDRESS > ../wallets/$1.addr
}

removeTxFiles() {
  rm -f tx.raw
  rm -f tx.signed
}

#exec command from text inside script eval ${cmd}