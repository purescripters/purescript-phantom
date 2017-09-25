module Example where

import Control.Monad.Aff (Aff, attempt, runAff_)
import Control.Monad.Aff.Console (log, logShow)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Console as Effc
import Control.Monad.Eff.Exception (message, stack)
import Data.Either (Either(..))
import Data.Maybe (fromMaybe)
import Data.Tuple (Tuple(..))
import PhantomJS.Page (createPage, customHeadersRaw, evaluate, injectJs, open, png, render)
import PhantomJS.Phantom (PHANTOMJS, exit)
import Prelude

-- Some examples of using PhantomJS.Page module.
-- Run the following in project root...
--
-- pulp --watch build --include examples --main Example --to examples-output/test.js
--
-- Then change to the examples-output directory and run the file with phantom.
--
-- cd examples-output
-- phantomjs test.js

main :: forall eff. Eff ( console :: CONSOLE, phantomjs :: PHANTOMJS | eff ) Unit
main = runAff_ Effc.logShow do
  log "--------"
  a <- attempt $ screenshotRedPage
  case a of
    Left err -> do
      _ <- log $ ("Error: " <> (message err))
      log $ "Stack: " <> (fromMaybe "No stack trace." (stack err))
    Right val -> do
      log "Screenshot with red background captured. See examples-output/pageRendering.png"

  log "--------"

  b <- attempt $ getParagraphsFromPage
  case b of
    Left err -> do
      log $ "Error: " <> (message err)
      log $ "Stack: " <> (fromMaybe "No stack trace." (stack err))
    Right val -> do
      log "Paragraph content successfully retrieved."
      logShow val
  log "--------"

  c <- attempt $ failureFunction
  case c of
    Left err -> do
      log $ "Error: " <> (message err)
      log $ "Stack: " <> (fromMaybe "No stack trace." (stack err))
    Right val -> do
      log "This should not succeed."
  log "--------"

  liftEff $ exit 0

failureFunction :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE | eff ) Unit
failureFunction = do
  page <- createPage
  customHeadersRaw page [
    Tuple "user-agent" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
  ]
  log ("Fetching page...")
  open page "http://eawefawfewaexample.com"
  injectJs page "assets/fileDoesNotExist.js"
  render page "pageRender.png" png

screenshotRedPage :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE | eff ) Unit
screenshotRedPage = do
  page <- createPage
  customHeadersRaw page [
    Tuple "user-agent" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
  ]
  log ("Fetching page...")
  open page "http://example.com"
  injectJs page "assets/backgroundRed.js"
  render page "pageRender.png" png

getParagraphsFromPage :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE | eff ) (Array String)
getParagraphsFromPage = do
  page <- createPage
  customHeadersRaw page [
    Tuple "user-agent" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
  ]
  log ("Fetching page...")
  open page "http://example.com"
  injectJs page "assets/getParagraphContent.js"
  content <- evaluate page "getParagraphContent"
  pure content
