module Test.PhantomJS.Page
  ( pageTests
  ) where

import Prelude

import Control.Monad.Except (runExcept)
import Effect.Aff (attempt, error, killFiber)
import Effect.Console (log)
import Effect.Class (liftEffect)
import Data.Array (length)
import Data.Either (isRight, isLeft, Either(..))
import Foreign (readInt)
import PhantomJS.File (exists, remove)
import PhantomJS.Page (RenderSettings, clearPageErrors, createPage, evaluate, getSilencedErrors, injectJs, jpeg, open, png, render, silencePageErrors, wait)
import Test.PhantomJS.Paths (getTempFolder, getTestHtmlFile, getTestHtmlFileWithErrors)
import Test.Unit (TestSuite, describe, it)
import Test.Unit.Assert (assert)

testImageRender :: String -> RenderSettings -> TestSuite
testImageRender filename renderSettings = do
  it ("should render test.html to " <> filename) do
    tempFolder <- liftEffect $ getTempFolder
    testHtmlFile <- liftEffect $ getTestHtmlFile

    let image = tempFolder <> filename
    _ <- attempt $ remove image
    p <- createPage
    _ <- open p testHtmlFile
    _ <- render p image renderSettings
    fileExists <- (exists image)
    _ <- attempt $ remove image
    assert (tempFolder <> filename <> " is not there.") fileExists

pageTests :: TestSuite
pageTests = do
  describe "PhantomJS.Page" do
    describe "open" do
      it "should open test.html" do
        testHtmlFile <- liftEffect $ getTestHtmlFile
        p <- createPage
        u <- attempt $ open p testHtmlFile
        assert "open returned failure case" (isRight u)

      it "should fail when local asset not found." do
        p <- createPage
        u <- attempt $ open p "test-not-found.html"
        assert "open returned success case" (isLeft u)

    describe "render" do
      testImageRender "test.jpg" jpeg
      testImageRender "test.jpeg" jpeg
      testImageRender "test.png" png

    describe "inject and evaluate" do
      it "should inject test.js into page" do
        testHtmlFile <- liftEffect $ getTestHtmlFile
        p <- createPage
        _ <- open p testHtmlFile
        _ <- injectJs p "test/assets/return28.js"
        r <- evaluate p "return28"

        assert "did not return value 28" (runExcept (readInt r) == Right 28)

      it "should fail injecting a non-existant script." do
        testHtmlFile <- liftEffect $ getTestHtmlFile
        p <- createPage
        _ <- open p testHtmlFile
        u <- attempt $ injectJs p "does-not-exists.js"
        assert "succeeded to inject the file." (isLeft u)

      it "should fail running a non-existant function." do
        testHtmlFile <- liftEffect $ getTestHtmlFile
        p <- createPage
        _ <- open p testHtmlFile
        _ <- injectJs p "test/assets/return28.js"
        r <- attempt $ evaluate p "doesnotexist"
        assert "did run doesnotexist()" (isLeft r)

    describe "silencePageErrors, getSilencedErrors, clearPageErrors" do
      it "should open test-with-errors.html and collect the errors on the page" do
        testHtmlFile <- liftEffect $ getTestHtmlFileWithErrors
        p1 <- createPage
        p2 <- createPage

        errorFiber1 <- silencePageErrors p1
        errorFiber2 <- silencePageErrors p2
        u1 <- attempt $ open p1 testHtmlFile
        u2 <- attempt $ open p2 testHtmlFile

        killFiber (error "stopping silence") errorFiber1
        killFiber (error "stopping silence") errorFiber2

        liftEffect $ log ""
        wait 1100

        errors1 <- getSilencedErrors p1
        errors2 <- getSilencedErrors p2

        assert "did not throw an error" $ length errors1 > 0
        assert "did not throw an error" $ length errors2 > 0
        assert "opening the same page twice does not result in the same errors" $ errors1 == errors2

        clearPageErrors p1
        clearPageErrors p2

        clearedErrors1 <- getSilencedErrors p1
        clearedErrors2 <- getSilencedErrors p2

        assert "did not clear stored errors" $ clearedErrors1 == clearedErrors2 && clearedErrors1 == []
