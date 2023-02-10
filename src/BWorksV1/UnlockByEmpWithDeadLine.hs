{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}

module BWorksV1.UnlockByEmpWithDeadLine
  ( unlockByEmpWithDeadLineScript
  , unlockByEmpWithDeadLineScriptShortBs
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
data UnlockByEmpWithDeadLineRedeemer
  = UnlockByEmpWithDeadLineRedeemer
      { 
      } deriving (Prelude.Eq, Show)

data UnlockByEmpWithDeadLineDatum
  = UnlockByEmpWithDeadLineDatum
       { 
       jobDeadLine    :: Plutus.POSIXTime
      , unlockSignature   :: [Plutus.PubKeyHash]
      } deriving (Prelude.Eq, Show)

PlutusTx.unstableMakeIsData ''UnlockByEmpWithDeadLineDatum
PlutusTx.unstableMakeIsData ''UnlockByEmpWithDeadLineRedeemer

{-# INLINABLE mkValidator #-}
--validator logics here which verify the transaction is valid if it is signed by emp and match deadline
mkValidator :: UnlockByEmpWithDeadLineDatum -> UnlockByEmpWithDeadLineRedeemer ->  ScriptContext -> Bool
mkValidator (UnlockByEmpWithDeadLineDatum jobDeadLine unlockSignature) (UnlockByEmpWithDeadLineRedeemer ) scriptContext = 
  Plutus.txInfoValidRange txInfo `Interval.contains` jobDeadLineRange P.&&
  txSignedBy txInfo unlockSignature
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

unlockByEmpWithDeadLineScriptShortBs :: SBS.ShortByteString
unlockByEmpWithDeadLineScriptShortBs = SBS.toShort . LBS.toStrict $ serialise script

unlockByEmpWithDeadLineScript :: PlutusScript PlutusScriptV1
unlockByEmpWithDeadLineScript = PlutusScriptSerialised unlockByEmpWithDeadLineScriptShortBs