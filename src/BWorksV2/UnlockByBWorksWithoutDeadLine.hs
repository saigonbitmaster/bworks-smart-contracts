{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}

module BWorksV2.UnlockByBWorksWithOutDeadLine
  ( unlockByBWorksWithOutDeadLineScriptV2
  , unlockByBWorksWithOutDeadLineScriptShortBsV2
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

data UnlockByBWorksWithOutDeadLineRedeemer
  = UnlockByBWorksWithOutDeadLineRedeemer
      { 
      } deriving (Prelude.Eq, Show)

data UnlockByBWorksWithOutDeadLineDatum
  = UnlockByBWorksWithOutDeadLineDatum
      { 
      unlockSignature   :: Plutus.PubKeyHash
      } deriving (Prelude.Eq, Show)

PlutusTx.unstableMakeIsData ''UnlockByBWorksWithOutDeadLineDatum
PlutusTx.unstableMakeIsData ''UnlockByBWorksWithOutDeadLineRedeemer

{-# INLINABLE mkValidator #-}
--we will add validator logics here which verify the transaction is valid if it is signed by bWorks
mkValidator :: UnlockByBWorksWithOutDeadLineDatum -> UnlockByBWorksWithOutDeadLineRedeemer ->  ScriptContext -> Bool
mkValidator (UnlockByBWorksWithOutDeadLineDatum unlockSignature) (UnlockByBWorksWithOutDeadLineRedeemer {}) scriptContext = txSignedBy txInfo unlockSignature
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

unlockByBWorksWithOutDeadLineScriptShortBsV2 :: SBS.ShortByteString
unlockByBWorksWithOutDeadLineScriptShortBsV2 = SBS.toShort . LBS.toStrict $ serialise script

unlockByBWorksWithOutDeadLineScriptV2 :: PlutusScript PlutusScriptV2
unlockByBWorksWithOutDeadLineScriptV2 = PlutusScriptSerialised unlockByBWorksWithOutDeadLineScriptShortBsV2