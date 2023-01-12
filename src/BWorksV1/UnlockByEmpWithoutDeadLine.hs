{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}

module BWorksV1.UnlockByEmpWithoutDeadLine
  ( unlockByEmpWithoutDeadLineScript
  , unlockByEmpWithoutDeadLineScriptShortBs
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
data UnlockByEmpWithoutDeadLineRedeemer
  = UnlockByEmpWithoutDeadLineRedeemer
      { 
      } deriving (Prelude.Eq, Show)

data UnlockByEmpWithoutDeadLineDatum
  = UnlockByEmpWithoutDeadLineDatum
      { 
      } deriving (Prelude.Eq, Show)

PlutusTx.unstableMakeIsData ''UnlockByEmpWithoutDeadLineDatum
PlutusTx.unstableMakeIsData ''UnlockByEmpWithoutDeadLineRedeemer

{-# INLINABLE mkValidator #-}
--we will add validator logics here which verify the transaction is valid if it is signed by emp
mkValidator :: UnlockByEmpWithoutDeadLineDatum -> UnlockByEmpWithoutDeadLineRedeemer ->  ScriptContext -> Bool
mkValidator (UnlockByEmpWithoutDeadLineDatum {}) (UnlockByEmpWithoutDeadLineRedeemer {}) scriptContext = True

validator :: Plutus.Validator
validator = Plutus.mkValidatorScript
    $$(PlutusTx.compile [|| wrap ||])
 where
     wrap = Scripts.mkUntypedValidator mkValidator
     
script :: Plutus.Script
script = Plutus.unValidatorScript validator

unlockByEmpWithoutDeadLineScriptShortBs :: SBS.ShortByteString
unlockByEmpWithoutDeadLineScriptShortBs = SBS.toShort . LBS.toStrict $ serialise script

unlockByEmpWithoutDeadLineScript :: PlutusScript PlutusScriptV1
unlockByEmpWithoutDeadLineScript = PlutusScriptSerialised unlockByEmpWithoutDeadLineScriptShortBs