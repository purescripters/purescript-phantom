module Test.Main where

import Prelude (($), bind)
import Data.Enum (fromEnum)
import ExitCodes (ExitCode(Success))
import PhantomJS.Phantom (exit, PHANTOMJS)
import Control.Monad.Aff (launchAff, Canceler)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION)
import Test.Unit (describe, it)
import Test.Unit.Assert (assert)
import Test.Unit.Output.Simple (runTest)
import Test.PhantomJS.Phantom (phantomTests)


main
  :: forall eff
   . Eff (phantomjs :: PHANTOMJS, console :: CONSOLE, err :: EXCEPTION, avar :: AVAR | eff)
         (Canceler (phantomjs :: PHANTOMJS, console :: CONSOLE, avar :: AVAR | eff))
main = launchAff $ runTest do
  phantomTests

  describe "exit" $ do
    it "should exit" $ do
      liftEff $ exit (fromEnum Success)
      assert "failed to exit phantomjs" false
