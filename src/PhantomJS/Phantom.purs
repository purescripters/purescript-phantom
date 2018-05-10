module PhantomJS.Phantom
  ( Cookie(..)
  , CookieRec
  , Version(..)
  , VersionRec
  , isCookiesEnabled
  , setCookiesEnabled
  , cookies
  , getLibraryPath
  , setLibraryPath
  , version
  , addCookie
  , clearCookies
  , deleteCookie
  , exit
  , injectJs
  ) where

import Prelude
import Effect (Effect)

type CookieRec =
  { domain   :: String
  , httponly :: Boolean
  , name     :: String
  , path     :: String
  , secure   :: Boolean
  , value    :: String
  }

data Cookie = Cookie CookieRec

instance eqCookie :: Eq Cookie where
  eq (Cookie x) (Cookie y) =
    x.domain   == y.domain   &&
    x.httponly == y.httponly &&
    x.name     == y.name     &&
    x.path     == y.path     &&
    x.secure   == y.secure   &&
    x.value    == y.value

instance showCookie :: Show Cookie where
  show (Cookie x) =
    "{ domain: "   <> x.domain        <>
    ", httponly: " <> show x.httponly <>
    ", name: "     <> x.name          <>
    ", path: "     <> x.path          <>
    ", secure: "   <> show x.secure   <>
    ", value: "    <> x.value         <> " " <>
    "}"

type VersionRec =
  { major :: Int
  , minor :: Int
  , patch :: Int
  }

data Version = Version VersionRec

instance eqVersion :: Eq Version where
  eq (Version x) (Version y) =
    x.major == y.major &&
    x.minor == y.minor &&
    x.patch == y.patch

instance showVersion :: Show Version where
  show (Version x) =
    "{ major: " <> show x.major <>
    ", minor: " <> show x.minor <>
    ", patch: " <> show x.patch <> " " <>
    "}"

foreign import isCookiesEnabled :: Effect Boolean

foreign import setCookiesEnabled :: Boolean -> Effect Unit

cookies :: Effect (Array Cookie)
cookies = _cookies >>= pure <<< map Cookie
foreign import _cookies :: Effect (Array CookieRec)

foreign import getLibraryPath :: Effect String

foreign import setLibraryPath :: String -> Effect Unit

version :: Effect Version
version = _version >>= pure <<< Version
foreign import _version :: Effect VersionRec

addCookie :: Cookie -> Effect Boolean
addCookie (Cookie cookie) = _addCookie cookie
foreign import _addCookie :: CookieRec -> Effect Boolean

foreign import clearCookies :: Effect Unit

foreign import deleteCookie :: String -> Effect Boolean

foreign import exit :: Int -> Effect Unit

foreign import injectJs :: String -> Effect Boolean
