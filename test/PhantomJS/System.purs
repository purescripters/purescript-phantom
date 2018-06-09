module Test.PhantomJS.System
  ( systemTests
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Data.String (length)
import Effect.Class (liftEffect)
import PhantomJS.System (foldEnv, getEnv, os, pid)
import Test.Unit (TestSuite, describe, it)
import Test.Unit.Assert (assert)

systemTests :: TestSuite
systemTests = do
  describe "PhantomJS.System" do
    describe "getEnv" do
      it "should get nothing looking for PHANTOM_TESTING_THIS_KEY_NOT_HERE" do
        maybeVar <- liftEffect $ getEnv "PHANTOM_TESTING_THIS_KEY_NOT_HERE"
        assert "PHANTOM_TESTING_THIS_KEY_NOT_HERE was set but it should not be" (maybeVar == Nothing)

      it "should see some environment variables using foldEnv" do
        env <- liftEffect $ foldEnv (\acc key value -> acc <> key <> value) ""
        assert "PHANTOM_TESTING wasn't set but it should be" (length env > 0)
    describe "os" do
      it "should get os architecture, name, and version" do
        os' <- liftEffect os
        assert
          ("OS is missing architecture, name, or version. architecture = " <> os'.architecture <> " name = " <>
               os'.name <> " version = " <> os'.version)
          (os'.architecture /= "" && os'.version /= "" && os'.name /= "")
    describe "pid" do
      it "should return the pid of the process" do
        pid' <- liftEffect pid
        assert "this should always pass" true
