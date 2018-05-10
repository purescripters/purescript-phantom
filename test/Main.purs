module Test.Main where

import Prelude

import Data.Either (either)
import Data.List (length)
import Data.Foldable (fold)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (stack)
import PhantomJS.Phantom (exit)
import Test.PhantomJS.File (fileTests)
import Test.PhantomJS.Page (pageTests)
import Test.PhantomJS.Phantom (phantomTests)
import Test.PhantomJS.Stream (streamTests)
import Test.PhantomJS.System (systemTests)
import Test.Unit (collectResults, keepErrors)
import Test.Unit.Output.Simple (runTest)

main :: Effect Unit
main = runAff_ (either logError logSuccess) do
  list <- runTest do
    phantomTests
    pageTests
    fileTests
    systemTests
    streamTests

  results <- collectResults list
  let failed = keepErrors results

  liftEffect $ if length failed > 0
    then exit 1
    else exit 0
  where
  logError = liftEffect <<< log <<< fold <<< stack
  logSuccess _ = liftEffect $ log "Success"
