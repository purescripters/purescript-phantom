module Test.PhantomJS.File
  ( fileTests
  ) where

import Prelude

import Effect.Class (liftEffect)
import PhantomJS.File (exists, remove, write, read, FileMode(..))
import Test.PhantomJS.Paths (getTempFile)
import Test.Unit (describe, it, TestSuite)
import Test.Unit.Assert (assert)

fileTests :: TestSuite
fileTests = do
  describe "PhantomJS.File" do
    describe "remove, read, write, exists" do
      it "should write to temp.txt" do
        tempFile <- liftEffect $ getTempFile
        write tempFile "ABC" W
        a <- exists tempFile
        assert "temp.txt wasn't created." (a == true)

      it "should read 'ABC' from the file." do
        tempFile <- liftEffect $ getTempFile
        c <- read tempFile
        assert "the value 'ABC' wasn't in temp.txt." (c == "ABC")

      it "should remove the file" do
        tempFile <- liftEffect $ getTempFile
        remove tempFile
        b <- exists tempFile
        assert "temp.txt wasn't removed." (b == false)
