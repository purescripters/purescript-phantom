module Test.PhantomJS.Stream (
    streamTests
  ) where

import Data.Maybe (Maybe(..))
import Data.TextEncoder (Encoding(..))
import PhantomJS.File (FileMode(..), PHANTOMJSFS, remove)
import PhantomJS.Phantom (PHANTOMJS)
import PhantomJS.Stream (StreamSettings, close, open, readLine, withSettings, write, writeLine)
import Prelude (bind, discard, ($), (==))
import Test.PhantomJS.Paths (getTempFile)
import Test.PhantomJS.Phantom (liftEff)
import Test.Unit (describe, it, TestSuite)
import Test.Unit.Assert (assert)

settings :: StreamSettings
settings = withSettings A Utf8

streamTests :: forall eff. TestSuite (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | eff)
streamTests = do
  describe "PhantomJS.Stream" do
    describe "open, write, writeLine, readLine, close" do
      it "should write to temp.txt" do
        tempFile <- liftEff $ getTempFile
        s <- open tempFile settings         
        write s "ab"
        write s "c"
        writeLine s ""
        writeLine s "abc2"
        close s      
        s <- open tempFile (withSettings R Utf8)
        r1 <- readLine s
        r2 <- readLine s
        -- void $ traceShowM r1
        -- void $ traceShowM r2
        close s
        assert "temp file doesn't contain 'abc' on first line" (r1 == Just "abc")
        assert "temp file doesn't contain 'abc2' on second line" (r2 == Just "abc2")
        remove tempFile        