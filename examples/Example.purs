module Example where

import Prelude
import Control.Monad.Aff (Aff, attempt, runAff, launchAff)
import Data.Either(Either(..))
import Control.Monad.Eff (foreachE)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import PhantomJS.Page (open, render, jpeg, createPage, injectJs, evaluate, Page, customHeaders, hPair)
import PhantomJS.File (PHANTOMFS, openStream, writeStream, closeStream, forWritingIn, FileMode)
import PhantomJS.Phantom (PHANTOMJS, exit)

-- import Control.Monad.Eff.Exception
-- import Control.Monad.Except(runExcept, runExceptT)
-- import Control.Monad.Error.Class (catchError, throwError)

-- Some examples of using PhantomJS.Page module.
-- Run the following in project root...
--
-- pulp --watch build --include examples --main Example --to examples-output/test.js
--
-- Then change to the examples-output directory and run the file with phantom.
--
-- cd examples-output
-- phantomjs test.js

main :: forall t105.
  Aff
    ( console :: CONSOLE
    , phantomfs :: PHANTOMFS
    , phantomjs :: PHANTOMJS
    | t105
    )
    Unit
main = do
  a <- attempt $ runPhantom
  case a of
    Left err -> do
      liftEff $ log (show err)
      liftEff $ exit 0
    Right vals -> do
      liftEff $ log "Writing to file..."
      s <- openStream "TEST.txt" (forWritingIn "UTF-8")
      writeStream s "ttttttttttttt"
      closeStream s
      liftEff $ exit 0


runPhantom :: forall t49.
  Aff
    ( console :: CONSOLE
    | t49
    )
    (Array String)
runPhantom = do
  page <- createPage

  customHeaders page [
    hPair "user-agent" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
  ]

  liftEff $ log ("Fetching page...")

  -- Will fail
  -- open page "http://exampllllllle.com"

  open page "http://example.com"
  injectJs page "assets/backgroundRed.js"

  -- Will fail
  -- injectJs page "assets/getParagraphhhhhContent.js"

  injectJs page "assets/getParagraphContent.js"

  -- Will fail
  -- content <- attempt $ evaluate page "getParagraphhhContent"

  content <- evaluate page "getParagraphContent" :: forall e. Aff e (Array String)

  liftEff $ log (show content)

  pure content
  -- render page "pageRender.jpg" jpeg
