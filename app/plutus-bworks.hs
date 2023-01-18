
import Prelude
import Cardano.Api
import System.Directory
import System.FilePath.Posix ((</>))
import BWorksV1.UnlockByBWorksWithOutDeadLine (unlockByBWorksWithOutDeadLineScript)
import BWorksV1.UnlockByBWorksWithDeadLine (unlockByBWorksWithDeadLineScript)
import BWorksV1.UnlockByEmpWithDeadLine (unlockByEmpWithDeadLineScript)
import BWorksV1.UnlockByEmpWithoutDeadLine (unlockByEmpWithoutDeadLineScript)
import BWorksV1.SimpleToTest (simpleToTestScript)

main :: IO ()
main = do
  let bWorksV1 = "generated-plutus-scripts/bWorksV1"
  createDirectoryIfMissing True bWorksV1
  _ <- writeFileTextEnvelope (bWorksV1 </> "unlockByBWorksWithOutDeadLineScript.plutus") Nothing unlockByBWorksWithOutDeadLineScript
  _ <- writeFileTextEnvelope (bWorksV1 </> "unlockByBWorksWithDeadLineScript.plutus") Nothing unlockByBWorksWithDeadLineScript
  _ <- writeFileTextEnvelope (bWorksV1 </> "unlockByEmpWithDeadLineScript.plutus") Nothing unlockByEmpWithDeadLineScript
  _ <- writeFileTextEnvelope (bWorksV1 </> "unlockByEmpWithoutDeadLineScript.plutus") Nothing unlockByEmpWithoutDeadLineScript
    _ <- writeFileTextEnvelope (bWorksV1 </> "simpleToTestScript.plutus") Nothing simpleToTestScript
  return ()