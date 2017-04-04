module Example where

import Prelude (Unit, bind, ($), (<>), pure, discard)
import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Aff.Console (log, logShow)
import Data.Maybe (fromMaybe)
import Data.Either(Either(..))
import Control.Monad.Eff.Exception(message, stack)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import PhantomJS.Page (open, render, createPage, injectJs, evaluate, Page, customHeadersRaw, png)
import PhantomJS.Phantom (PHANTOMJS, exit)
import Data.Tuple (Tuple(..))

-- Some examples of using PhantomJS.Page module.
-- Run the following in project root...
--
-- pulp --watch build --include examples --main Example --to examples-output/test.js
--
-- Then change to the examples-output directory and run the file with phantom.
--
-- cd examples-output
-- phantomjs test.js

main :: forall eff. Aff ( console :: CONSOLE, phantomjs :: PHANTOMJS | eff ) Unit
main = do

  _ <- log "--------"
  a <- attempt $ screenshotRedPage
  case a of
    Left err -> do
      _ <- log $ ("Error: " <> (message err))
      log $ "Stack: " <> (fromMaybe "No stack trace." (stack err))
    Right val -> do
      log "Screenshot with red background captured."

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
      log "This will not succeed."
  log "--------"

  liftEff $ exit 0

failureFunction :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE | eff ) Page
failureFunction = do
  page <- createPage
  _ <- customHeadersRaw page [
    Tuple "user-agent" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
  ]
  _ <- log ("Fetching page...")
  _ <- open page "http://eawefawfewaexample.com"
  _ <- injectJs page "assets/fileDoesNotExist.js"
  render page "pageRender.png" png

screenshotRedPage :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE | eff ) Page
screenshotRedPage = do
  page <- createPage
  _ <- customHeadersRaw page [
    Tuple "user-agent" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
  ]
  _ <- log ("Fetching page...")
  _ <- open page "http://example.com"
  _ <- injectJs page "assets/backgroundRed.js"
  render page "pageRender.png" png

getParagraphsFromPage :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE | eff ) (Array String)
getParagraphsFromPage = do
  page <- createPage
  _ <- customHeadersRaw page [
    Tuple "user-agent" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
  ]
  _ <- log ("Fetching page...")
  _ <- open page "http://example.com"
  _ <- injectJs page "assets/getParagraphContent.js"
  content <- evaluate page "getParagraphContent" :: Aff _ (Array String)
  pure content
