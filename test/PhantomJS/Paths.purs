module Test.PhantomJS.Paths
  ( getOutputDir
  , getProjectRoot
  , getTestDir
  , getTempFolder
  , getTempFile
  , getTestHtmlFile
  , getTestHtmlFileWithErrors
  , getTestInjectScriptPath
  ) where

import Prelude

import Effect (Effect)
import Data.Maybe (fromMaybe)
import PhantomJS.System (getEnv)

-- If you're using the purescript-docker container the path will be /home/pureuser
-- otherwise you can set PHANTOM_TEST_PATH on command line.
-- e.g. PHANTOM_TEST_PATH=$(pwd) pulp test --runtime phantomjs
getProjectRoot :: Effect String
getProjectRoot = do
  mpath <- getEnv "PHANTOM_TEST_PATH"
  pure $ fromMaybe "/home/pureuser/" (appendTrailingSlash <$> mpath)
  where appendTrailingSlash = (flip append "/")

getOutputDir :: Effect String
getOutputDir = do
  p <- getProjectRoot
  pure $ p <> "output"

getTestDir :: Effect String
getTestDir = do
  p <- getProjectRoot
  pure $ p <> "test"

getTestInjectScriptPath :: Effect String
getTestInjectScriptPath = do
  p <- getTestDir
  pure $ p <> "/assets/sample.js"

getTestHtmlFile :: Effect String
getTestHtmlFile = do
  p <- getProjectRoot
  pure $ p <> "test/assets/test.html"

getTestHtmlFileWithErrors :: Effect String
getTestHtmlFileWithErrors = do
  p <- getProjectRoot
  pure $ p <> "test/assets/test-with-errors.html"

getTempFolder :: Effect String
getTempFolder = do
  p <- getProjectRoot
  pure $ p <> "test/assets/temp/"

getTempFile :: Effect String
getTempFile = do
  p <- getTempFolder
  pure $ p <> "temp.txt"
