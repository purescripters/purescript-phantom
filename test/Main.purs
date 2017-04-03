module Test.Main where

import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import PhantomJS.Phantom (PHANTOMJS)
import PhantomJS.File (PHANTOMJSFS)
import Prelude (discard, Unit)
import Test.PhantomJS.Page (pageTests)
import Test.PhantomJS.File (fileTests)
import Test.PhantomJS.Phantom (phantomTests)
import Test.Unit.Main (runTest)
import Test.Unit.Console (TESTOUTPUT)
--import Test.Unit.Output.Simple (runTest)


-- liftEff :: forall eff a. Eff eff a -> Aff eff a
-- liftEff = EffClass.liftEff

main :: forall t11.
        Eff
          ( console :: CONSOLE
          , testOutput :: TESTOUTPUT
          , avar :: AVAR
          , phantomjs :: PHANTOMJS
          , phantomjsfs :: PHANTOMJSFS
          | t11
          )
          Unit
main = runTest do
  phantomTests
  pageTests
  fileTests
