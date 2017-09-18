module Test.PhantomJS.Stream (
    streamTests
  ) where

import Data.Maybe (Maybe(..))
import Data.TextEncoder (Encoding(..))
import Debug.Trace (traceShowM)
import PhantomJS.File (FileMode(..), PHANTOMJSFS, remove)
import PhantomJS.Phantom (PHANTOMJS)
import PhantomJS.Stream (StreamSettings, close, open, read, readLine, seek, withSettings, write, writeLine)
import Prelude (bind, discard, void, ($), (&&), (==))
import Test.PhantomJS.Paths (getTempFile)
import Test.PhantomJS.Phantom (liftEff)
import Test.Unit (describe, it, TestSuite)
import Test.Unit.Assert (assert)

settings :: StreamSettings
settings = withSettings A Utf8

streamTests :: forall eff. TestSuite (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | eff)
streamTests = do
  describe "PhantomJS.Stream" do
    describe "open, write, writeLine, readLine, seek, close" do
      it "should write to temp.txt" do
        tempFile <- liftEff $ getTempFile
        s <- open tempFile settings         
        write s "ab"
        write s "c"
        writeLine s ""
        writeLine s "abc2"
        close s      
        s2 <- open tempFile (withSettings R Utf8)
        r1 <- readLine s2
        r2 <- readLine s2
        seek s2 1
        r3 <- readLine s2
        -- void $ traceShowM r1
        -- void $ traceShowM r3
        close s2
        assert "temp file doesn't contain 'abc' on first line" (r1 == Just "abc")
        assert "temp file doesn't contain 'abc2' on second line" (r2 == Just "abc2")
        assert "temp file doesn't contain 'bc' on second line starting at position 1" (r3 == Just "bc")
        remove tempFile        