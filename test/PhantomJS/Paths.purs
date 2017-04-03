module Test.PhantomJS.Paths
  ( outputDir
  , projectRoot
  , testDir
  , tempFolder
  , tempFile
  , testHtmlFile
  , testInjectScriptPath
  ) where

import Data.Maybe (fromMaybe)
import Data.Monoid (append)
import PhantomJS.System (getEnv)
import Prelude ((<>), (=<<), (<<<), pure, flip, ($))

-- If you're using the purescript-docker container the path will be /home/pureuser
-- otherwise you can set PHANTOM_TEST_PATH on command line.
-- e.g. PHANTOM_TEST_PATH=$(pwd) pulp test --runtime phantomjs
projectRoot :: String
projectRoot = fromMaybe "/home/pureuser/" (appendTrailingSlash =<< getEnv "PHANTOM_TEST_PATH")
  where appendTrailingSlash = pure <<< flip append "/"

outputDir :: String
outputDir = projectRoot <> "output"

testDir :: String
testDir = projectRoot <> "test"

testInjectScriptPath :: String
testInjectScriptPath = testDir <> "/assets/sample.js"

testHtmlFile :: String
testHtmlFile = projectRoot <> "test/assets/test.html"

tempFolder :: String
tempFolder = projectRoot <> "test/assets/temp/"

tempFile :: String
tempFile = tempFolder <> "temp.txt"
