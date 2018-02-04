module Test.PhantomJS.Page
  ( pageTests
  ) where

import PhantomJS.Page

import Control.Monad.Aff (Aff, attempt, error, killFiber)
import Control.Monad.Aff.Console (CONSOLE, log)
import Data.Array (length)
import Data.Either (isRight, isLeft)
import PhantomJS.File (PHANTOMJSFS, exists, remove)
import PhantomJS.Phantom (PHANTOMJS)
import Prelude (bind, discard, ($), (&&), (<>), (==), (>))
import Test.PhantomJS.Paths (getTempFolder, getTestHtmlFile, getTestHtmlFileWithErrors)
import Test.PhantomJS.Phantom (liftEff)
import Test.Unit (TestSuite, describe, it)
import Test.Unit.Assert (assert)

testImageRender :: forall e.
  String
  -> RenderSettings
     -> TestSuite
         ( phantomjsfs :: PHANTOMJSFS
         , phantomjs :: PHANTOMJS
         | e
         )
testImageRender filename renderSettings = do
  it ("should render test.html to " <> filename) do
    tempFolder <- liftEff $ getTempFolder
    testHtmlFile <- liftEff $ getTestHtmlFile

    let image = tempFolder <> filename
    _ <- attempt $ remove image
    p <- createPage
    _ <- open p testHtmlFile
    _ <- render p image renderSettings
    fileExists <- (exists image)
    _ <- attempt $ remove image
    assert (tempFolder <> filename <> " is not there.") fileExists

pageTests :: forall e. TestSuite (console :: CONSOLE, phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | e)
pageTests = do
  describe "PhantomJS.Page" do
    describe "open" do
      it "should open test.html" do
        testHtmlFile <- liftEff $ getTestHtmlFile
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
        testHtmlFile <- liftEff $ getTestHtmlFile
        p <- createPage
        _ <- open p testHtmlFile
        _ <- injectJs p "test/assets/return28.js"
        r <- evaluate p "return28" :: forall e. Aff (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | e) Int
        assert "did not return value 28" (r == 28)

      it "should fail injecting a non-existant script." do
        testHtmlFile <- liftEff $ getTestHtmlFile
        p <- createPage
        _ <- open p testHtmlFile
        u <- attempt $ injectJs p "does-not-exists.js"
        assert "succeeded to inject the file." (isLeft u)

      it "should fail running a non-existant function." do
        testHtmlFile <- liftEff $ getTestHtmlFile
        p <- createPage
        _ <- open p testHtmlFile
        _ <- injectJs p "test/assets/return28.js"
        r <- attempt $ evaluate p "doesnotexist" :: forall e. Aff (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | e) Int
        assert "did run doesnotexist()" (isLeft r)

    describe "silencePageErrors, getSilencedErrors, clearPageErrors" do
      it "should open test-with-errors.html and collect the errors on the page" do
        testHtmlFile <- liftEff $ getTestHtmlFileWithErrors
        p1 <- createPage
        p2 <- createPage

        errorFiber1 <- silencePageErrors p1
        errorFiber2 <- silencePageErrors p2
        u1 <- attempt $ open p1 testHtmlFile
        u2 <- attempt $ open p2 testHtmlFile

        killFiber (error "stopping silence") errorFiber1
        killFiber (error "stopping silence") errorFiber2

        log ""
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

