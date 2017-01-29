module Test.Main where

import Control.Monad.Aff (Aff, launchAff, Canceler)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff) as EffClass
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Enum (fromEnum)
import ExitCodes (ExitCode(Success))
import PhantomJS.Phantom (exit, PHANTOMJS)
import PhantomJS.File (PHANTOMJSFS)
import Prelude (($), bind)
import Test.PhantomJS.Page (pageTests)
import Test.PhantomJS.File (fileTests)
import Test.PhantomJS.Phantom (phantomTests)
import Test.Unit (describe, it)
import Test.Unit.Assert (assert)
import Test.Unit.Output.Simple (runTest)


liftEff :: forall eff a. Eff eff a -> Aff eff a
liftEff = EffClass.liftEff

main
  :: forall eff
   . Eff (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS, console :: CONSOLE, err :: EXCEPTION, avar :: AVAR | eff)
         (Canceler (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS, console :: CONSOLE, avar :: AVAR | eff))
main = launchAff $ runTest do
  phantomTests
  pageTests
  fileTests

  describe "exit" $ do
    it "should exit" $ do
      liftEff $ exit (fromEnum Success)
      assert "failed to exit phantomjs" false
