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
import Control.Monad.Eff (Eff)
import Data.Maybe (fromMaybe)
import PhantomJS.Phantom (PHANTOMJS)
import PhantomJS.System (getEnv)

-- If you're using the purescript-docker container the path will be /home/pureuser
-- otherwise you can set PHANTOM_TEST_PATH on command line.
-- e.g. PHANTOM_TEST_PATH=$(pwd) pulp test --runtime phantomjs
getProjectRoot :: forall e. Eff (phantomjs :: PHANTOMJS | e) String
getProjectRoot = do
  mpath <- getEnv "PHANTOM_TEST_PATH"
  pure $ fromMaybe "/home/pureuser/" (appendTrailingSlash <$> mpath)
  where appendTrailingSlash = (flip append "/")

getOutputDir :: forall e. Eff (phantomjs :: PHANTOMJS | e) String
getOutputDir = do
  p <- getProjectRoot
  pure $ p <> "output"

getTestDir :: forall e. Eff (phantomjs :: PHANTOMJS | e) String
getTestDir = do
  p <- getProjectRoot
  pure $ p <> "test"

getTestInjectScriptPath :: forall e. Eff (phantomjs :: PHANTOMJS | e) String
getTestInjectScriptPath = do
  p <- getTestDir
  pure $ p <> "/assets/sample.js"

getTestHtmlFile :: forall e. Eff (phantomjs :: PHANTOMJS | e) String
getTestHtmlFile = do
  p <- getProjectRoot
  pure $ p <> "test/assets/test.html"

getTestHtmlFileWithErrors :: forall e. Eff (phantomjs :: PHANTOMJS | e) String
getTestHtmlFileWithErrors = do
  p <- getProjectRoot
  pure $ p <> "test/assets/test-with-errors.html"

getTempFolder :: forall e. Eff (phantomjs :: PHANTOMJS | e) String
getTempFolder = do
  p <- getProjectRoot
  pure $ p <> "test/assets/temp/"

getTempFile :: forall e. Eff (phantomjs :: PHANTOMJS | e) String
getTempFile = do
  p <- getTempFolder
  pure $ p <> "temp.txt"
