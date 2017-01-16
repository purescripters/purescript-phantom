module Example where

import Prelude
import Control.Monad.Aff
import Control.Monad.Eff
import Control.Monad.Eff.Exception
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Error.Class (catchError)
import PhantomJS.Phantom (PHANTOMJS, exit)
import PhantomJS.Page (open, render, jpeg, createPage, injectJs, evaluate)
import Data.Either


-- Some examples of using PhantomJS.Page module.
-- Run the following in project root...
--
-- pulp build --include test --main Example --to test/test.js
--
-- Then change to the test directory and run the file with phantom.
--
-- cd test
-- phantomjs test.js
--
-- You should see the following, and have a pageRendering.jpg file added to the
-- test directory.
--
-- (Right ["This domain is established to be used for illustrative examples in documents. You may use this\n    domain in examples without prior coordination or asking for permission.","More information..."])

main :: forall e. Eff (err :: EXCEPTION, console :: CONSOLE, phantomjs :: PHANTOMJS | e)
                      (Canceler ( console :: CONSOLE, phantomjs :: PHANTOMJS  | e))
main = launchAff $ do
  --liftEff $ (log "Running scripts...")
  page <- createPage

  -- remote file
  open page "http://example.com"

  -- can also render local documents...
  -- open page "README.md"
  --
  attempt $ injectJs page "assets/backgroundRed.js"

  -- Handling failures needs some work
  -- liftEff $
  --   either (const $ log "Couldn't inject backgroundRed.js")
  --          (const $ log "backgroundRed.js injected") a
  --
  attempt $ injectJs page "assets/getParagraphContent.js"
  -- liftEff $ either
  --   (const $ log "Couldn't inject getParagraphContent.js")
  --   (const $ log "getParagraphContent.js injected") b
  --
  content <- attempt $ evaluate page "getParagraphContent"
  --
  liftEff $ log (show content)
  --
  (render page "pageRender.jpg" jpeg)
  --
  liftEff $ exit 0
