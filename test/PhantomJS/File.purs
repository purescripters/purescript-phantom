module Test.PhantomJS.File
  ( fileTests
  ) where

import PhantomJS.Phantom (PHANTOMJS)
import PhantomJS.File (PHANTOMJSFS, exists, remove, write, read, FileMode(..))
import Prelude (bind, (==), discard)
import Test.Unit (describe, it, TestSuite)
import Test.Unit.Assert (assert)
import Test.PhantomJS.Paths (tempFile)

fileTests :: forall eff. TestSuite (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | eff)
fileTests = do
  describe "PhantomJS.File" do
    describe "remove, read, write, exists" do
      it "should write to temp.txt" do
        write tempFile "ABC" W
        a <- exists tempFile
        assert "the file wasn't created." (a == true)

      it "should read 'ABC' from the file." do
        c <- read tempFile
        assert "the value 'ABC' wasn't in the file." (c == "ABC")

      it "should remove the file" do
        remove tempFile
        b <- exists tempFile
        assert "the file wasn't removed." (b == false)
