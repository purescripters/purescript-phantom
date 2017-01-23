module Test.PhantomJS.Page
  ( pageTests
  ) where

import PhantomJS.Phantom (PHANTOMJS)
import PhantomJS.Page
import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Free (Free)
import Data.Either (isRight, isLeft)
import PhantomJS.File (PHANTOMJSFS, exists, remove)
import Prelude (Unit, bind, ($), (<>), (==))
import Test.Unit (Test, TestF, describe, it)
import Test.Unit.Assert (shouldEqual, assert)

-- If you're using the purescript-docker container,
-- otherwise set this to the absolute path of where
-- the project was cloned
projectRoot :: String
projectRoot = "/home/pureuser/src/"

-- Assuming we're running in project root right now.
-- Should look into using the docker container used by
-- Phantom.Tests
testHtmlFile :: String
testHtmlFile = projectRoot <> "test/assets/test.html"

tempFolder :: String
tempFolder = projectRoot <> "test/assets/temp/"

-- testImageRender :: forall a. String -> RenderSettings -> Test a
testImageRender :: forall eff.
  String
  -> RenderSettings
     -> Free
          (TestF
             ( phantomjsfs :: PHANTOMJSFS
             , phantomjs :: PHANTOMJS
             | eff
             )
          )
          Unit
testImageRender filename renderSettings = do
  it ("should render test.html to " <> filename) do
    let image = tempFolder <> filename
    attempt $ remove image
    p <- createPage
    open p testHtmlFile
    render p image renderSettings
    fileExists <- (exists image)
    attempt $ remove image
    assert (tempFolder <> filename <> " is not there.") fileExists

pageTests :: forall eff. Free (TestF (phantomjsfs :: PHANTOMJSFS, phantomjs :: PHANTOMJS | eff)) Unit
pageTests = do
  describe "PhantomJS.Page" do
    describe "open" do
      it "should open test.html" do
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
        p <- createPage
        open p testHtmlFile
        injectJs p "test/assets/return28.js"
        r <- evaluate p "return28" :: forall e. Aff e Int
        assert "did not return value 28" (r == 28)

      it "should fail injecting a non-existant script." do
        p <- createPage
        open p testHtmlFile
        u <- attempt $ injectJs p "does-not-exists.js"
        assert "succeeded to inject the file." (isLeft u)

      it "should fail running a non-existant function." do
        p <- createPage
        open p testHtmlFile
        injectJs p "test/assets/return28.js"
        r <- attempt $ evaluate p "doesnotexist" :: forall e. Aff e Int
        assert "did run doesnotexist()" (isLeft r)
