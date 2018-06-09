module Test.PhantomJS.Phantom where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import PhantomJS.Phantom (Cookie(..), Version(..), addCookie, clearCookies, cookies, deleteCookie, getLibraryPath, injectJs, isCookiesEnabled, setCookiesEnabled, setLibraryPath, version)
import Test.PhantomJS.Paths (getOutputDir, getTestInjectScriptPath)
import Test.Unit (describe, it, TestSuite)
import Test.Unit.Assert (shouldEqual)

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

foreign import isScriptInjected :: Effect Boolean

phantomTests :: TestSuite
phantomTests = do
  describe "cookiesEnabled" do
    it "should return true by default for isCookiesEnabled" do
      isEnabled <- liftEffect isCookiesEnabled
      isEnabled `shouldEqual` true

  describe "setCookiesEnabled" do
    it "should set cookiesEnabled to the given value" do
      isEnabled <- liftEffect $ (setCookiesEnabled false) *> isCookiesEnabled
      isEnabled `shouldEqual` false

    it "should revert it back to the default value" do
      isEnabled <- liftEffect $ (setCookiesEnabled true) *> isCookiesEnabled
      isEnabled `shouldEqual` true

  describe "cookies" do
    it "should initially return an empty array" do
      cookies' <- liftEffect cookies
      cookies' `shouldEqual` []

  describe "getLibraryPath" do
    it "should get the library path" do
      libraryPath <- liftEffect getLibraryPath
      outputDir <- liftEffect getOutputDir
      libraryPath `shouldEqual` outputDir

  describe "setLibraryPath" do
    it "should set the library path" do
      let newPath = "/home/foo/bar"
      libraryPath <- liftEffect $ (setLibraryPath newPath) *> getLibraryPath
      libraryPath `shouldEqual` newPath

    it "should revert it back to the default value" do
      outputDir <- liftEffect getOutputDir
      libraryPath <- liftEffect $ (setLibraryPath outputDir) *> getLibraryPath
      libraryPath `shouldEqual` outputDir

  describe "version" do
    it "should get the phantomjs version" do
      version' <- liftEffect version
      version' `shouldEqual` expectedVersion

  describe "addCookie" do
    it "should add a cookie successfully" do
      isSuccess <- liftEffect $ addCookie sampleCookie
      isSuccess `shouldEqual` true
      cookies' <- liftEffect cookies
      cookies' `shouldEqual` [sampleCookie]

  describe "clearCookies" do
    it "should clear the cookies" do
      liftEffect clearCookies
      cookies' <- liftEffect cookies
      cookies' `shouldEqual` []

  describe "deleteCookie" do
    it "should delete a cookie" do
      isSuccess <- liftEffect $ addCookie sampleCookie
      isSuccess `shouldEqual` true
      cookiesBefore <- liftEffect cookies
      cookiesBefore `shouldEqual` [sampleCookie]

      _ <- liftEffect $ deleteCookie "foo"
      cookiesAfter <- liftEffect cookies
      cookiesAfter `shouldEqual` []

  describe "injectJs" do
    it "should inject a script" do

      testInjectScriptPath <- liftEffect getTestInjectScriptPath
      isScriptInjectedBefore <- liftEffect isScriptInjected

      isScriptInjectedBefore `shouldEqual` false
      isSuccess <- liftEffect $ injectJs testInjectScriptPath
      isSuccess `shouldEqual` true

      isScriptInjectedAfter <- liftEffect isScriptInjected
      isScriptInjectedAfter `shouldEqual` true
