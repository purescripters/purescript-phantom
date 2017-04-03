module Test.Main where

import Control.Bind ((=<<))
import Control.Monad.Aff (launchAff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Aff.Class (liftAff)
import Control.Monad.Aff.Console (logShow)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import Data.List (length)
import PhantomJS.File (PHANTOMJSFS)
import PhantomJS.Phantom (PHANTOMJS, exit)
import Prelude (discard, Unit, ($), bind, (>>=), (>))
import Test.PhantomJS.File (fileTests)
import Test.PhantomJS.Page (pageTests)
import Test.PhantomJS.Phantom (phantomTests)
import Test.PhantomJS.System (systemTests)
import Test.Unit (collectResults, collectTests, describe, it, keepErrors)
import Test.Unit.Assert (assert)
import Test.Unit.Console (TESTOUTPUT)
import Test.Unit.Output.Simple (runTest)

main = do
  list <- runTest do
    phantomTests
    pageTests
    fileTests
    systemTests

  results <- collectResults list
  let failed = keepErrors results

  if length failed > 0
    then liftEff $ exit 1
    else liftEff $ exit 0
