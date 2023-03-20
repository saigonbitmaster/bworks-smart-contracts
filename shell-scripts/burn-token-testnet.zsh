#!/usr/bin/zsh
# Usage:
# $ ./burn-token-testnet.zsh $tokenName $payment_address $policy_directory_path $tokenamount $txHash
#
# For eg:
# $ ./burn-token-testnet.zsh bworks `cat payment1.addr` bworks-policy 5000 d448e8722cba3abbdfa994ee4cfc6318ebad0e307bb535214979d11bea8bee22

tokenName=$1
tokenHex=$(echo -n $tokenName | xxd -b -ps -c 80 | tr -d '\n')
address=$2
policypath=$3
tokenamount=$4
txHash=$5
utxo=$(/opt/cardano/cardano-wallet/cardano-cli query utxo --address $address --testnet-magic 1 | grep $txHash)
txHash=`echo $utxo | awk '{print $1"#"$2}'`
funds=`echo $utxo | awk '{print $3}'`
remains=`echo $utxo | awk '{print $6}'`
policyid=`/opt/cardano/cardano-wallet/cardano-cli transaction policyid --script-file $policypath/policy.script`

burnfee="0"
burnoutput="0"

echo "You have $funds lovelace and $remains $tokenName token"
if [ $tokenamount -gt $remains ]
then
        echo "You cannot burn more number of token than you have !"
        exit
fi
remains=$(expr $remains - $tokenamount)

echo "building burning raw for tokenName $tokenName | tokenHex $tokenHex"
/opt/cardano/cardano-wallet/cardano-cli transaction build-raw --fee $burnfee --tx-in $txHash --tx-out $address+$burnoutput+"$remains $policyid.$tokenHex" --mint="-$tokenamount $policyid.$tokenHex" --minting-script-file $policypath/policy.script --out-file burningnofee.raw

echo "calculating burning fee for $tokenamount tokenName $tokenName | tokenHex $tokenHex"
burnfee=$(/opt/cardano/cardano-wallet/cardano-cli transaction calculate-min-fee --tx-body-file burningnofee.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 --testnet-magic 1 --protocol-params-file protocol.json | cut -d " " -f1)
burnoutput=$(expr $funds - $burnfee)
echo "Your burning fee : $burnfee"
if [ $burnfee -gt $funds ]
then
        echo "You don't have enough lovelace for tx fee !"
        exit
else
        echo "Your remain lovelace after burn token : $burnoutput"
        echo "Your remain $tokenName token : $remains"
fi

echo "building burning raw with fee for tokenName $tokenName | tokenHex $tokenHex"
/opt/cardano/cardano-wallet/cardano-cli transaction build-raw --fee $burnfee --tx-in $txHash --tx-out $address+$burnoutput+"$remains $policyid.$tokenHex" --mint="-$tokenamount $policyid.$tokenHex" --minting-script-file $policypath/policy.script --out-file burning.raw

echo "Signing tnx for burning $tokenamount tokenName $tokenName"
/opt/cardano/cardano-wallet/cardano-cli transaction sign  --signing-key-file payment1.skey  --signing-key-file $policypath/policy.skey --testnet-magic 1  --tx-body-file burning.raw --out-file burning.signed

echo "Burning ...!"
/opt/cardano/cardano-wallet/cardano-cli transaction submit --tx-file burning.signed --testnet-magic 1

echo "Done!"
