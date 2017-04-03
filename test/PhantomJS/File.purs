module Test.PhantomJS.File
  ( fileTests
  ) where

import PhantomJS.Phantom (PHANTOMJS)
import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Free (Free)
import Data.Either (isRight, isLeft, Either(Right))
import PhantomJS.File (PHANTOMJSFS, exists, remove, write, read, FileMode(..))
import Prelude (Unit, bind, ($), (<>), (==), map, unit, pure, discard)
import Test.Unit (Test, TestF, describe, it, TestSuite)
import Test.Unit.Assert (shouldEqual, assert)
import Data.Foreign (readString)
import Control.Monad.Except(runExcept)
import Test.PhantomJS.Paths (projectRoot, testHtmlFile, tempFolder, tempFile)

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
