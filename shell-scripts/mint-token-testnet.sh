#!/bin/bash
# Usage:
# $ ./mint-token-testnet.sh $tokenName $payment_address $policy_directory_path $tokenamount $txHash
#
# For eg:
# $ ./mint-token-testnet.sh bworks `cat payment1.addr` bworks-policy 5000 d448e8722cba3abbdfa994ee4cfc6318ebad0e307bb535214979d11bea8bee22

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

mintfee="0"
mintoutput="0"

re='^[0-9]+$'

echo "building minting raw for tokenName $tokenName | tokenHex $tokenHex"
if ! [[ $remains =~ $re ]]
then
        remains=$tokenamount
        /opt/cardano/cardano-wallet/cardano-cli transaction build-raw --fee $mintfee --tx-in $txHash --tx-out $address+$mintoutput+"$tokenamount $policyid.$tokenHex" --mint="$tokenamount $policyid.$tokenHex" --minting-script-file $policypath/policy.script --out-file mintingnofee.raw
else
        remains=$(expr $remains + $tokenamount)
        /opt/cardano/cardano-wallet/cardano-cli transaction build-raw --fee $mintfee --tx-in $txHash --tx-out $address+$mintoutput+"$remains $policyid.$tokenHex" --mint="$tokenamount $policyid.$tokenHex" --minting-script-file $policypath/policy.script --out-file mintingnofee.raw
fi

echo "calculating minting fee for $tokenamount tokenName $tokenName | tokenHex $tokenHex"
mintfee=$(/opt/cardano/cardano-wallet/cardano-cli transaction calculate-min-fee --tx-body-file mintingnofee.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 --testnet-magic 1 --protocol-params-file protocol.json | cut -d " " -f1)
mintoutput=$(expr $funds - $mintfee)
echo "Your minting fee : $mintfee"
if [ $mintfee -gt $funds ]
then
        echo "You don't have enough lovelace for tx fee !"
        exit
else
        echo "Your remain lovelace after mint token : $mintoutput"
        echo "You will have $remains $tokenName token after mint"
fi

echo "building minting raw with fee for tokenName $tokenName | tokenHex $tokenHex"
/opt/cardano/cardano-wallet/cardano-cli transaction build-raw --fee $mintfee --tx-in $txHash --tx-out $address+$mintoutput+"$remains $policyid.$tokenHex" --mint="$tokenamount $policyid.$tokenHex" --minting-script-file $policypath/policy.script --out-file minting.raw

echo "Signing tnx for minting $tokenamount tokenName $tokenName"
/opt/cardano/cardano-wallet/cardano-cli transaction sign  --signing-key-file payment1.skey  --signing-key-file $policypath/policy.skey --testnet-magic 1  --tx-body-file minting.raw --out-file minting.signed

echo "Mintning ...!"
/opt/cardano/cardano-wallet/cardano-cli transaction submit --tx-file minting.signed --testnet-magic 1

echo "Done!"
