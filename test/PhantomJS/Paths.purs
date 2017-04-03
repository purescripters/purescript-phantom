module Test.PhantomJS.Paths
  ( outputDir
  , projectRoot
  , testDir
  , tempFolder
  , tempFile
  , testHtmlFile
  , testInjectScriptPath
  ) where

import Prelude ((<>))
-- If you're using the purescript-docker container,
-- otherwise set this to the absolute path of where
-- the project was cloned
projectRoot :: String
projectRoot = "/home/pureuser/"

outputDir :: String
outputDir = projectRoot <> "output"

testDir :: String
testDir = projectRoot <> "test"

testInjectScriptPath :: String
testInjectScriptPath = testDir <> "/assets/sample.js"

-- Assuming we're running in project root right now.
-- Should look into using the docker container used by
-- Phantom.Tests
testHtmlFile :: String
testHtmlFile = projectRoot <> "test/assets/test.html"

tempFolder :: String
tempFolder = projectRoot <> "test/assets/temp/"

tempFile :: String
tempFile = tempFolder <> "temp.txt"
