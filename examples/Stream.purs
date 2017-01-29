module Example.Stream where

import Prelude (Unit, bind, ($))
import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Aff.Console (log, logShow)
import Data.Maybe (fromMaybe)
import Data.Either(Either(..))
import Control.Monad.Eff.Exception(stack)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import PhantomJS.File (PHANTOMJSFS, FileMode(..))
import PhantomJS.Stream (open, close, readLine, write, writeLine, withSettings)
import PhantomJS.Phantom (PHANTOMJS, exit)

-- Some examples of using PhantomJS.Page module.
-- Run the following in project root...
--
-- pulp --watch build --include examples --main Example.Stream --to examples-output/stream.js
--
-- Then change to the examples-output directory and run the file with phantom.
--
-- cd examples-output
-- phantomjs stream.js

main :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE, phantomjsfs :: PHANTOMJSFS | eff ) Unit
main = do
  r <- attempt $ readFile
  case r of
    Left e -> do
      log "Err:"
      log $ fromMaybe "No Stack" (stack e)
      logShow e
    Right rr -> log "OK"

  w <- attempt $ writeFile
  case w of
    Left e -> do
      log "Err:"
      logShow (stack e)
      logShow e
    Right rr -> log "OK"

  liftEff $ exit 0

readFile :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE, phantomjsfs :: PHANTOMJSFS | eff ) Unit
readFile = do
  s <- open "assets/test.txt" (withSettings R "utf8")
  l <- readLine s
  logShow l
  close s


writeFile :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE, phantomjsfs :: PHANTOMJSFS | eff ) Unit
writeFile = do
  s <- open "test.txt" (withSettings W "utf8")
  write s "I can only hope that the original Horace "
  writeLine s "was taken in by "
  write s "a kind family."
  close s
