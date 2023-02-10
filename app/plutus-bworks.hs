
import Prelude
import Cardano.Api
import System.Directory
import System.FilePath.Posix ((</>))
--bWorks Plutus V1
import BWorksV1.UnlockByBWorksWithOutDeadLine (unlockByBWorksWithOutDeadLineScript)
import BWorksV1.UnlockByBWorksWithDeadLine (unlockByBWorksWithDeadLineScript)
import BWorksV1.UnlockByEmpWithDeadLine (unlockByEmpWithDeadLineScript)
import BWorksV1.UnlockByEmpWithoutDeadLine (unlockByEmpWithoutDeadLineScript)
import BWorksV1.SimpleToTest (simpleToTestScript)

--bWorks Plutus V2
import BWorksV2.UnlockByBWorksWithOutDeadLine (unlockByBWorksWithOutDeadLineScriptV2)
import BWorksV2.UnlockByBWorksWithDeadLine (unlockByBWorksWithDeadLineScriptV2)
import BWorksV2.UnlockByEmpWithDeadLine (unlockByEmpWithDeadLineScriptV2)
import BWorksV2.UnlockByEmpWithoutDeadLine (unlockByEmpWithoutDeadLineScriptV2)

main :: IO ()
main = do
  let bWorksV1 = "generated-plutus-scripts/bWorksV1"
  let bWorksV2 = "generated-plutus-scripts/bWorksV2"
  createDirectoryIfMissing True bWorksV1
  createDirectoryIfMissing True bWorksV2
  _ <- writeFileTextEnvelope (bWorksV1 </> "unlockByBWorksWithOutDeadLineScript.plutus") Nothing unlockByBWorksWithOutDeadLineScript
  _ <- writeFileTextEnvelope (bWorksV1 </> "unlockByBWorksWithDeadLineScript.plutus") Nothing unlockByBWorksWithDeadLineScript
  _ <- writeFileTextEnvelope (bWorksV1 </> "unlockByEmpWithDeadLineScript.plutus") Nothing unlockByEmpWithDeadLineScript
  _ <- writeFileTextEnvelope (bWorksV1 </> "unlockByEmpWithoutDeadLineScript.plutus") Nothing unlockByEmpWithoutDeadLineScript
  
  --Plutus V2
  _ <- writeFileTextEnvelope (bWorksV2 </> "unlockByBWorksWithOutDeadLineScript.plutus") Nothing unlockByBWorksWithOutDeadLineScriptV2
  _ <- writeFileTextEnvelope (bWorksV2 </> "unlockByBWorksWithDeadLineScript.plutus") Nothing unlockByBWorksWithDeadLineScriptV2
  _ <- writeFileTextEnvelope (bWorksV2 </> "unlockByEmpWithDeadLineScript.plutus") Nothing unlockByEmpWithDeadLineScriptV2
  _ <- writeFileTextEnvelope (bWorksV2 </> "unlockByEmpWithoutDeadLineScript.plutus") Nothing unlockByEmpWithoutDeadLineScriptV2

  _ <- writeFileTextEnvelope (bWorksV1 </> "simpleToTestScript.plutus") Nothing simpleToTestScript

  return ()