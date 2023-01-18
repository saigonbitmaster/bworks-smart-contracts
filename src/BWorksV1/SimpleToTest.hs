{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE TypeFamilies      #-}

module BWorksV1.SimpleToTest
  ( SimpleToTestDatum(..)
  , SimpleToTestRedeemer(..)
  , simpleToTestScript
  , simpleToTestAsShortBs
  ) where

import Prelude hiding (($), (&&), (==))
import Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV1)
import Codec.Serialise
import Data.ByteString.Lazy qualified as LBS
import Data.ByteString.Short qualified as SBS
import Plutus.Script.Utils.Typed qualified as Scripts
import Plutus.V1.Ledger.Api qualified as Plutus
import Plutus.V1.Ledger.Contexts (ScriptContext)
import PlutusTx qualified
import PlutusTx.Prelude hiding (Semigroup ((<>)), unless, (.))


data SimpleToTestDatum = SimpleToTestDatum Integer
data SimpleToTestRedeemer = SimpleToTestRedeemer Integer

PlutusTx.unstableMakeIsData ''SimpleToTestDatum
PlutusTx.unstableMakeIsData ''SimpleToTestRedeemer

{-# INLINABLE mkValidator #-}
mkValidator :: SimpleToTestDatum -> SimpleToTestRedeemer ->  ScriptContext -> Bool
mkValidator (SimpleToTestDatum d) (SimpleToTestRedeemer r) _ = d == r

validator :: Plutus.Validator
validator = Plutus.mkValidatorScript
    $$(PlutusTx.compile [|| wrap ||])
 where
     wrap = Scripts.mkUntypedValidator mkValidator

script :: Plutus.Script
script = Plutus.unValidatorScript validator

simpleToTestAsShortBs :: SBS.ShortByteString
simpleToTestAsShortBs = SBS.toShort . LBS.toStrict $ serialise script

simpleToTestScript :: PlutusScript PlutusScriptV1
simpleToTestScript = PlutusScriptSerialised simpleToTestAsShortBs