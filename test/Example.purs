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
-- pulp --watch build --include test --main Example --to examples/test.js
--
-- Then change to the test directory and run the file with phantom.
--
-- cd examples
-- phantomjs test.js
--
-- You should see the following, and have a pageRendering.jpg file added to the
-- test directory.
--
-- (Right ["This domain is established to be used for illustrative examples in documents. You may use this\n    domain in examples without prior coordination or asking for permission.","More information..."])

main :: forall t63.
  Aff
    ( console :: CONSOLE
    , phantomjs :: PHANTOMJS
    | t63
    )
    Unit
main = do
  a <- attempt $ runPhantom
  case a of
    Left err -> do
      liftEff $ log (show err)
      liftEff $ exit 0
    Right val -> pure val


runPhantom :: forall t54.
  Aff
    ( console :: CONSOLE
    , phantomjs :: PHANTOMJS
    | t54
    )
    Unit
runPhantom = do
  --liftEff $ (log "Running scripts...")
  page <- createPage

  -- remote file
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

  content <- attempt $ evaluate page "getParagraphContent"

  liftEff $ log (show content)

  (render page "pageRender.jpg" jpeg)

  liftEff $ exit 0
