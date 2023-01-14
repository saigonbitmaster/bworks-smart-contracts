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
import PlutusTx.Prelude qualified as P
import Plutus.V1.Ledger.Interval as Interval


data UnlockByBWorksWithDeadLineRedeemer
  = UnlockByBWorksWithDeadLineRedeemer
      { 
      } deriving (Prelude.Eq, Show)

data UnlockByBWorksWithDeadLineDatum
  = UnlockByBWorksWithDeadLineDatum
       { 
       jobDeadLine    :: Plutus.POSIXTime
      , unlockSignature   :: [Plutus.PubKeyHash]
      } deriving (Prelude.Eq, Show)

PlutusTx.unstableMakeIsData ''UnlockByBWorksWithDeadLineRedeemer
PlutusTx.unstableMakeIsData ''UnlockByBWorksWithDeadLineDatum


{-# INLINABLE mkValidator #-}
--we will add validator logics here to verify the transaction is valid if it is signed by bWorks
mkValidator :: UnlockByBWorksWithDeadLineDatum -> UnlockByBWorksWithDeadLineRedeemer ->  ScriptContext -> Bool
mkValidator (UnlockByBWorksWithDeadLineDatum jobDeadLine unlockSignature) (UnlockByBWorksWithDeadLineRedeemer ) scriptContext = 
  Plutus.txInfoValidRange txInfo `Interval.contains` jobDeadLineRange P.&&
  Plutus.txInfoSignatories txInfo P.== unlockSignature
  where  
    jobDeadLineRange:: Plutus.POSIXTimeRange
    jobDeadLineRange = Interval.from jobDeadLine
    txInfo :: Plutus.TxInfo
    txInfo = Plutus.scriptContextTxInfo scriptContext

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