{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}

module BWorksV1.UnlockByBWorksWithDeadLine
  ( unlockByBWorksWithDeadLineScript
  , unlockByBWorksWithDeadLineScriptShortBs
  ) where

import Prelude hiding (($), (&&), (==))
import Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV1)
import Codec.Serialise
import Data.ByteString.Lazy qualified as LBS
import Data.ByteString.Short qualified as SBS
import Plutus.V1.Ledger.Api qualified as Plutus
import PlutusTx qualified
import PlutusTx.Prelude hiding (Semigroup ((<>)), unless, (.))
import Plutus.V1.Ledger.Contexts (ScriptContext)
import Plutus.Script.Utils.Typed qualified as Scripts

--we will define datum & redeemer data here to meet the validator requirements
data UnlockByBWorksWithDeadLineRedeemer
  = UnlockByBWorksWithDeadLineRedeemer
      { 
      } deriving (Prelude.Eq, Show)
data UnlockByBWorksWithDeadLineDatum
  = UnlockByBWorksWithDeadLineDatum
      { 
      } deriving (Prelude.Eq, Show)

PlutusTx.unstableMakeIsData ''UnlockByBWorksWithDeadLineRedeemer
PlutusTx.unstableMakeIsData ''UnlockByBWorksWithDeadLineDatum

{-# INLINABLE mkValidator #-}
--we will add validator logics here which verify the transaction is valid if it is signed by bWorks
mkValidator :: UnlockByBWorksWithDeadLineDatum -> UnlockByBWorksWithDeadLineRedeemer ->  ScriptContext -> Bool
mkValidator (UnlockByBWorksWithDeadLineDatum {}) (UnlockByBWorksWithDeadLineRedeemer {}) scriptContext = True

validator :: Plutus.Validator
validator = Plutus.mkValidatorScript
    $$(PlutusTx.compile [|| wrap ||])
 where
     wrap = Scripts.mkUntypedValidator mkValidator
     
script :: Plutus.Script
script = Plutus.unValidatorScript validator

unlockByBWorksWithDeadLineScriptShortBs :: SBS.ShortByteString
unlockByBWorksWithDeadLineScriptShortBs = SBS.toShort . LBS.toStrict $ serialise script

unlockByBWorksWithDeadLineScript :: PlutusScript PlutusScriptV1
unlockByBWorksWithDeadLineScript = PlutusScriptSerialised unlockByBWorksWithDeadLineScriptShortBs