module Test.PhantomJS.File
  ( fileTests
  ) where

import PhantomJS.File (PHANTOMJSFS, exists, remove, write, read, FileMode(..))
import PhantomJS.Phantom (PHANTOMJS)
import Prelude (bind, (==), discard, ($))
import Test.PhantomJS.Paths (getTempFile)
import Test.PhantomJS.Phantom (liftEff)
import Test.Unit (describe, it, TestSuite)
import Test.Unit.Assert (assert)

fileTests :: forall eff. TestSuite (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | eff)
fileTests = do
  describe "PhantomJS.File" do
    describe "remove, read, write, exists" do
      it "should write to temp.txt" do
        tempFile <- liftEff $ getTempFile
        write tempFile "ABC" W
        a <- exists tempFile
        assert "temp.txt wasn't created." (a == true)

      it "should read 'ABC' from the file." do
        tempFile <- liftEff $ getTempFile
        c <- read tempFile
        assert "the value 'ABC' wasn't in temp.txt." (c == "ABC")

      it "should remove the file" do
        tempFile <- liftEff $ getTempFile
        remove tempFile
        b <- exists tempFile
        assert "temp.txt wasn't removed." (b == false)
