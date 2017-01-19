module ExampleFS where

import Prelude (Unit, bind, ($), (<>), pure)
import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Aff.Console (log, logShow)
import Data.Maybe (fromMaybe)
import Data.Either(Either(..))
import Control.Monad.Eff.Exception(message, stack)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import PhantomJS.Stream (PHANTOMJSFS, FileMode(..), open, close, readLine, write, writeLine, withSettings)
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
  -- s <- open "test.txt" (forWritingIn "utf8")
  s <- open "test.txt" (withSettings R "utf8")
  l <- readLine s
  logShow l
  close s


writeFile :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE, phantomjsfs :: PHANTOMJSFS | eff ) Unit
writeFile = do
  -- s <- open "test.txt" (forWritingIn "utf8")
  s <- open "test.txt" (withSettings RW "utf8")
  write s "ap"
  writeLine s "ap"
  write s "ap"
  close s
