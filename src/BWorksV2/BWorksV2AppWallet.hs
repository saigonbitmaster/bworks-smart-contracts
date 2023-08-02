{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}

module BWorksV2.BWorksV2AppWallet
  ( bWorksV2AppWalletScriptShortBsV2
  , bWorksV2AppWalletScriptV2
  ) where

import Prelude hiding (($), (&&), (==))
import Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV2)
import Codec.Serialise
import Data.ByteString.Lazy qualified as LBS
import Data.ByteString.Short qualified as SBS
import Plutus.V2.Ledger.Api qualified as Plutus
import PlutusTx qualified
import PlutusTx.Prelude hiding (Semigroup ((<>)), unless, (.))
import Plutus.V2.Ledger.Contexts (ScriptContext, txSignedBy)
import Plutus.Script.Utils.Typed qualified as Scripts
import PlutusTx.Prelude qualified as P

data UnlockByEmpWithoutDeadLineRedeemer
  = UnlockByEmpWithoutDeadLineRedeemer
      { 
      } deriving (Prelude.Eq, Show)

data UnlockByEmpWithoutDeadLineDatum
  = UnlockByEmpWithoutDeadLineDatum
      {
      unlockSignature :: Plutus.PubKeyHash 
      } deriving (Prelude.Eq, Show)

PlutusTx.unstableMakeIsData ''UnlockByEmpWithoutDeadLineDatum
PlutusTx.unstableMakeIsData ''UnlockByEmpWithoutDeadLineRedeemer

{-# INLINABLE mkValidator #-}
--we will add validator logics here which verify the transaction is valid if it is signed by emp
--if the unlock transaction was signed by a wallet with pkh in datum then unlock otherwise fail
--this worked with both cli inline datum and meshjs unlock setRequiredSigners([pkh])
mkValidator :: UnlockByEmpWithoutDeadLineDatum -> UnlockByEmpWithoutDeadLineRedeemer ->  ScriptContext -> Bool
mkValidator (UnlockByEmpWithoutDeadLineDatum unlockSignature) (UnlockByEmpWithoutDeadLineRedeemer {}) scriptContext = 
  P.elem unlockSignature signatures
  where  
    txInfo :: Plutus.TxInfo
    txInfo = Plutus.scriptContextTxInfo scriptContext
    signatures :: [Plutus.PubKeyHash]
    signatures = Plutus.txInfoSignatories txInfo

validator :: Plutus.Validator
validator = Plutus.mkValidatorScript
    $$(PlutusTx.compile [|| wrap ||])
 where
     wrap = Scripts.mkUntypedValidator mkValidator
     
script :: Plutus.Script
script = Plutus.unValidatorScript validator

bWorksV2AppWalletScriptShortBsV2 :: SBS.ShortByteString
bWorksV2AppWalletScriptShortBsV2 = SBS.toShort . LBS.toStrict $ serialise script

bWorksV2AppWalletScriptV2 :: PlutusScript PlutusScriptV2
bWorksV2AppWalletScriptV2 = PlutusScriptSerialised bWorksV2AppWalletScriptShortBsV2