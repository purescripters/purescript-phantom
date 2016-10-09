module Test.PhantomJS.Phantom where

import Prelude (Unit, bind, ($), (*>), (<>))
import PhantomJS.Phantom
import Control.Monad.Free (Free)
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff) as EffClass
import Test.Unit (TestF, describe, it)
import Test.Unit.Assert (shouldEqual)


liftEff :: forall eff a. Eff eff a -> Aff eff a
liftEff = EffClass.liftEff

-- | Tests should be run with the purescript docker container
projectDir :: String
projectDir = "/home/pureuser/src/"

outputDir :: String
outputDir = projectDir <> "output"

testDir :: String
testDir = projectDir <> "test"

scriptPath :: String
scriptPath = testDir <> "/sample.js"

expectedVersion :: Version
expectedVersion = Version { major: 2, minor: 1, patch: 1 }

sampleCookie :: Cookie
sampleCookie = Cookie
  { domain:   ".purescript.org"
  , httponly: true
  , name:     "foo"
  , path:     "/"
  , secure:   true
  , value:    "foobar"
  }

foreign import isScriptInjected :: forall eff. Eff (phantomjs :: PHANTOMJS | eff) Boolean

phantomTests :: forall eff. Free (TestF (phantomjs :: PHANTOMJS | eff)) Unit
phantomTests = do
  describe "cookiesEnabled" do
    it "should return true by default for isCookiesEnabled" do
      isEnabled <- liftEff isCookiesEnabled
      isEnabled `shouldEqual` true

  describe "setCookiesEnabled" do
    it "should set cookiesEnabled to the given value" do
      isEnabled <- liftEff $ (setCookiesEnabled false) *> isCookiesEnabled
      isEnabled `shouldEqual` false

    it "should revert it back to the default value" do
      isEnabled <- liftEff $ (setCookiesEnabled true) *> isCookiesEnabled
      isEnabled `shouldEqual` true

  describe "cookies" do
    it "should initially return an empty array" do
      cookies' <- liftEff cookies
      cookies' `shouldEqual` []

  describe "getLibraryPath" do
    it "should get the library path" do
      libraryPath <- liftEff getLibraryPath
      libraryPath `shouldEqual` outputDir

  describe "setLibraryPath" do
    it "should set the library path" do
      let newPath = "/home/foo/bar"
      libraryPath <- liftEff $ (setLibraryPath newPath) *> getLibraryPath
      libraryPath `shouldEqual` newPath

    it "should revert it back to the default value" do
      libraryPath <- liftEff $ (setLibraryPath outputDir) *> getLibraryPath
      libraryPath `shouldEqual` outputDir

  describe "version" do
    it "should get the phantomjs version" do
      version' <- liftEff version
      version' `shouldEqual` expectedVersion

  describe "addCookie" do
    it "should add a cookie successfully" do
      isSuccess <- liftEff $ addCookie sampleCookie
      isSuccess `shouldEqual` true
      cookies' <- liftEff cookies
      cookies' `shouldEqual` [sampleCookie]

  describe "clearCookies" do
    it "should clear the cookies" do
      liftEff clearCookies
      cookies' <- liftEff cookies
      cookies' `shouldEqual` []

  describe "deleteCookie" do
    it "should delete a cookie" do
      isSuccess <- liftEff $ addCookie sampleCookie
      isSuccess `shouldEqual` true
      cookiesBefore <- liftEff cookies
      cookiesBefore `shouldEqual` [sampleCookie]

      liftEff $ deleteCookie "foo"
      cookiesAfter <- liftEff cookies
      cookiesAfter `shouldEqual` []

  describe "injectJs" do
    it "should inject a script" do
      isScriptInjectedBefore <- liftEff isScriptInjected
      isScriptInjectedBefore `shouldEqual` false

      isSuccess <- liftEff $ injectJs scriptPath
      isSuccess `shouldEqual` true

      isScriptInjectedAfter <- liftEff isScriptInjected
      isScriptInjectedAfter `shouldEqual` true
