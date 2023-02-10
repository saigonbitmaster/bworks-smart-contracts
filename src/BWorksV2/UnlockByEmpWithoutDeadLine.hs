{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}

module BWorksV2.UnlockByEmpWithoutDeadLine
  ( unlockByEmpWithoutDeadLineScriptV2
  , unlockByEmpWithoutDeadLineScriptShortBsV2
  ) where

import Prelude hiding (($), (&&), (==))
import Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV2)
import Codec.Serialise
import Data.ByteString.Lazy qualified as LBS
import Data.ByteString.Short qualified as SBS
import Plutus.V1.Ledger.Api qualified as Plutus
import PlutusTx qualified
import PlutusTx.Prelude hiding (Semigroup ((<>)), unless, (.))
import Plutus.V1.Ledger.Contexts (ScriptContext, txSignedBy)
import Plutus.Script.Utils.Typed qualified as Scripts

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
mkValidator :: UnlockByEmpWithoutDeadLineDatum -> UnlockByEmpWithoutDeadLineRedeemer ->  ScriptContext -> Bool
mkValidator (UnlockByEmpWithoutDeadLineDatum unlockSignature) (UnlockByEmpWithoutDeadLineRedeemer {}) scriptContext = txSignedBy txInfo unlockSignature
  where
    txInfo :: Plutus.TxInfo
    txInfo = Plutus.scriptContextTxInfo scriptContext

validator :: Plutus.Validator
validator = Plutus.mkValidatorScript
    $$(PlutusTx.compile [|| wrap ||])
 where
     wrap = Scripts.mkUntypedValidator mkValidator
     
script :: Plutus.Script
script = Plutus.unValidatorScript validator

unlockByEmpWithoutDeadLineScriptShortBsV2 :: SBS.ShortByteString
unlockByEmpWithoutDeadLineScriptShortBsV2 = SBS.toShort . LBS.toStrict $ serialise script

unlockByEmpWithoutDeadLineScriptV2 :: PlutusScript PlutusScriptV2
unlockByEmpWithoutDeadLineScriptV2 = PlutusScriptSerialised unlockByEmpWithoutDeadLineScriptShortBsV2