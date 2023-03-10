{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}

module BWorksV1.UnlockByBWorksWithOutDeadLine
  ( unlockByBWorksWithOutDeadLineScript
  , unlockByBWorksWithOutDeadLineScriptShortBs
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
--validator logics here which verify the transaction is valid if it is signed by bWorks
mkValidator :: UnlockByBWorksWithOutDeadLineDatum -> UnlockByBWorksWithOutDeadLineRedeemer ->  ScriptContext -> Bool
mkValidator (UnlockByBWorksWithOutDeadLineDatum unlockSignature) (UnlockByBWorksWithOutDeadLineRedeemer ) scriptContext = 
  txSignedBy txInfo unlockSignature
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

unlockByBWorksWithOutDeadLineScriptShortBs :: SBS.ShortByteString
unlockByBWorksWithOutDeadLineScriptShortBs = SBS.toShort . LBS.toStrict $ serialise script

unlockByBWorksWithOutDeadLineScript :: PlutusScript PlutusScriptV1
unlockByBWorksWithOutDeadLineScript = PlutusScriptSerialised unlockByBWorksWithOutDeadLineScriptShortBs