module Test.Main where

import Control.Monad.Aff (message, runAff_)
import Control.Monad.Aff.AVar (AVAR, makeEmptyVar)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (stack)
import Data.Either (Either(..))
import Data.List (length)
import PhantomJS.File (PHANTOMJSFS)
import PhantomJS.Phantom (PHANTOMJS, exit)
import Prelude (Unit, bind, discard, show, ($), (<>), (>))
import Test.PhantomJS.File (fileTests)
import Test.PhantomJS.Page (pageTests)
import Test.PhantomJS.Phantom (phantomTests)
import Test.PhantomJS.System (systemTests)
import Test.Unit (collectResults, keepErrors)
import Test.Unit.Output.Simple (runTest)

main :: forall e.
        Eff
          ( console :: CONSOLE
          , avar :: AVAR
          , phantomjs :: PHANTOMJS
          , phantomjsfs :: PHANTOMJSFS
          | e
          )
          Unit
main = runAff_ (case _ of
    Left err -> do
      log $ "ERROR: " <> message err
      log $ show (stack err)
    Right r -> log "Success"
  ) $ do
  b <- makeEmptyVar  
  list <- runTest do
    phantomTests
    pageTests
    fileTests
    systemTests

  results <- collectResults list
  let failed = keepErrors results

  if length failed > 0
    then liftEff $ exit 1
    else liftEff $ exit 0
