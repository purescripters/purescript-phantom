module QuickStart where

import Prelude ((>>=), bind, discard)
import Data.Enum (fromEnum)
import PhantomJS.Phantom (version, exit)
import Control.Monad.Eff.Console (logShow)

main = do
  version >>= logShow
  exit 0
