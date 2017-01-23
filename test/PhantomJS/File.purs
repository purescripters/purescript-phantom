module Test.PhantomJS.File
  ( fileTests
  ) where

import PhantomJS.Phantom (PHANTOMJS)
import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Free (Free)
import Data.Either (isRight, isLeft, Either(Right))
import PhantomJS.File (PHANTOMJSFS, exists, remove, write, read, FileMode(..))
import Prelude (Unit, bind, ($), (<>), (==), map, unit, pure)
import Test.Unit (Test, TestF, describe, it)
import Test.Unit.Assert (shouldEqual, assert)
import Data.Foreign (readString)
import Control.Monad.Except(runExcept)


-- If you're using the purescript-docker container,
-- otherwise set this to the absolute path of where
-- the project was cloned
projectRoot :: String
projectRoot = "/home/pureuser/src/"

-- Assuming we're running in project root right now.
-- Should look into using the docker container used by
-- Phantom.Tests
testHtmlFile :: String
testHtmlFile = projectRoot <> "test/assets/test.html"

tempFolder :: String
tempFolder = projectRoot <> "test/assets/temp/"

tempFile :: String
tempFile = tempFolder <> "temp.txt"

fileTests :: forall eff. Free (TestF (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | eff)) Unit
fileTests = do
  describe "PhantomJS.File" do
    describe "remove, read, write, exists" do
      it "should write to temp.txt" do
        write tempFile "ABC" W
        a <- exists tempFile
        assert "the file wasn't created." (a == true)

      it "should read 'ABC' from the file." do
        b <- read tempFile
        let c = runExcept $ readString b
        assert "the value 'ABC' wasn't in the file." (c == (Right "ABC"))

      it "should remove the file" do
        remove tempFile
        b <- exists tempFile
        assert "the file wasn't removed." (b == false)
