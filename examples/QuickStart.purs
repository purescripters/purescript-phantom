module QuickStart where

import Prelude ((>>=), bind)
import Data.Enum (fromEnum)
import ExitCodes (ExitCode(Success))
import PhantomJS.Phantom (version, exit)
import Control.Monad.Eff.Console (logShow)

main = do
  version >>= logShow
  exit (fromEnum Success)
