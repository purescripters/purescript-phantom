module Test.Main where

import Prelude

import Control.Monad.Aff (Error, runAff_)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (stack)
import Data.Either (either)
import Data.List (length)
import Data.Maybe (maybe)
import Data.Monoid (mempty)
import PhantomJS.File (PHANTOMJSFS)
import PhantomJS.Phantom (PHANTOMJS, exit)
import Test.PhantomJS.File (fileTests)
import Test.PhantomJS.Page (pageTests)
import Test.PhantomJS.Phantom (phantomTests)
import Test.PhantomJS.Stream (streamTests)
import Test.PhantomJS.System (systemTests)
import Test.Unit (collectResults, keepErrors)
import Test.Unit.Output.Simple (runTest)

stack' :: Error -> String
stack' = maybe mempty id <<< stack

main :: forall e.
        Eff
          ( console :: CONSOLE
          , avar :: AVAR
          , phantomjs :: PHANTOMJS
          , phantomjsfs :: PHANTOMJSFS
          | e
          )
          Unit
main = runAff_ (either (log <<< stack') (\_ -> log "Success")) do
  list <- runTest do
    phantomTests
    pageTests
    fileTests
    systemTests
    streamTests

  results <- collectResults list
  let failed = keepErrors results

  if length failed > 0
    then liftEff $ exit 1
    else liftEff $ exit 0
