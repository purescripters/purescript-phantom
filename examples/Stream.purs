module Example.Stream where

import Control.Monad.Aff (Aff, attempt, launchAff_, runAff_)
import Control.Monad.Aff.Console (log, logShow)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Console as Effc
import Control.Monad.Eff.Exception (stack)
import Data.Either (Either(..))
import Data.Maybe (fromMaybe)
import Data.TextEncoder (Encoding(..))
import PhantomJS.File (FileMode(..), PHANTOMJSFS)
import PhantomJS.Phantom (PHANTOMJS, exit)
import PhantomJS.Stream (open, close, readLine, write, writeLine, withSettings)
import Prelude (Unit, bind, ($), discard)

-- Some examples of using PhantomJS.Page module.
-- Run the following in project root...
--
-- pulp --watch build --include examples --main Example.Stream --to examples-output/stream.js
--
-- Then change to the examples-output directory and run the file with phantom.
--
-- cd examples-output
-- phantomjs stream.js

main :: forall eff. Eff ( phantomjs :: PHANTOMJS, console :: CONSOLE, phantomjsfs :: PHANTOMJSFS | eff ) Unit
main = runAff_ Effc.logShow do
  readFile
  writeFile
  log "Done. See examples-output/test.txt for newly written file."
  liftEff $ exit 0

readFile :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE, phantomjsfs :: PHANTOMJSFS | eff ) Unit
readFile = do
  s <- open "assets/test.txt" (withSettings R Utf8)
  l <- readLine s
  logShow l
  close s

writeFile :: forall eff. Aff ( phantomjs :: PHANTOMJS, console :: CONSOLE, phantomjsfs :: PHANTOMJSFS | eff ) Unit
writeFile = do
  s <- open "test.txt" (withSettings W Utf8)
  write s "I can only hope that the original Horace "
  writeLine s "was taken in by "
  write s "a kind family."
  close s
