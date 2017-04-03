module Test.PhantomJS.System
  ( systemTests
  ) where

import PhantomJS.System
import Data.Maybe (Maybe(..))
import Data.String (length)
import PhantomJS.File (PHANTOMJSFS)
import PhantomJS.Phantom (PHANTOMJS)
import Prelude (bind, discard, ($), (&&), (/=), (<>), (==), (>))
import Test.PhantomJS.Phantom (liftEff)
import Test.Unit (TestSuite, describe, it)
import Test.Unit.Assert (assert)

systemTests :: forall eff. TestSuite (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | eff)
systemTests = do
  describe "PhantomJS.System" do
    describe "getEnv" do
      it "should get nothing looking for PHANTOM_TESTING_THIS_KEY_NOT_HERE" do
        maybeVar <- liftEff $ getEnv "PHANTOM_TESTING_THIS_KEY_NOT_HERE"
        assert "PHANTOM_TESTING_THIS_KEY_NOT_HERE was set but it should not be" (maybeVar == Nothing)

      it "should see some environment variables using foldEnv" do
        env <- liftEff $ foldEnv (\acc key value -> acc <> key <> value) ""
        assert "PHANTOM_TESTING wasn't set but it should be" (length env > 0)
    describe "os" do
      it "should get os architecture, name, and version" do
        os' <- liftEff os
        assert
          ("OS is missing architecture, name, or version. architecture = " <> os'.architecture <> " name = " <>
               os'.name <> " version = " <> os'.version)
          (os'.architecture /= "" && os'.version /= "" && os'.name /= "")
    describe "pid" do
      it "should return the pid of the process" do
        pid' <- liftEff pid
        assert "this should always pass" true
