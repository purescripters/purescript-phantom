-- | This module defines types and functions for working with file streams.

module PhantomJS.Stream
  ( Stream
  , StreamSettings
  , open
  , write
  , writeLine
  , readLine
  , close
  , withSettings
  , seek
  , read
  ) where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Data.TextEncoder (Encoding)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (toForeign, Foreign)
import PhantomJS.File (FileMode, FilePath, toForeignFileMode)

-- http://stackoverflow.com/questions/8509339/what-is-the-most-common-encoding-of-each-language
-- http://www.iana.org/assignments/character-sets/character-sets.xhtml
-- | The filemode and character set settings needed to open a stream.
newtype StreamSettings = StreamSettings
  { mode :: FileMode
  , charset :: Encoding
  }

derive instance genericStreamSettings :: Generic StreamSettings _
instance showStreamSettings :: Show StreamSettings where
  show = genericShow

toForeignStreamSettings :: StreamSettings -> Foreign
toForeignStreamSettings (StreamSettings { mode, charset }) = toForeign
  { mode : toForeignFileMode mode
  , charset : show charset
  }

-- | Helper for creating a StreamSettings type
withSettings :: FileMode -> Encoding -> StreamSettings
withSettings mode charset = StreamSettings { mode, charset }

foreign import data Stream :: Type

-- | Open a file stream
open :: FilePath -> StreamSettings -> Aff Stream
open fp fs = fromEffectFnAff $ open_ fp (toForeignStreamSettings fs)
foreign import open_ :: FilePath -> Foreign -> EffectFnAff Stream

-- | Write to a file stream
write :: Stream -> String -> Aff Unit
write s t = fromEffectFnAff $ write_ s t
foreign import write_ :: Stream -> String -> EffectFnAff Unit

-- | Write a line to a file stream
writeLine :: Stream -> String -> Aff Unit
writeLine s t = fromEffectFnAff $ writeLine_ s t
foreign import writeLine_ :: Stream -> String -> EffectFnAff Unit

-- | Read a line from a file stream
readLine :: Stream -> Aff (Maybe String)
readLine stream = fromEffectFnAff $ readLine_ stream Just Nothing
foreign import readLine_ :: forall a.  Stream -> (a -> Maybe a) -> (Maybe a) -> EffectFnAff (Maybe String)

-- | Read the entire stream
read :: Stream -> Aff (Maybe String)
read stream = fromEffectFnAff $ read_ stream Just Nothing
foreign import read_ :: forall a.  Stream -> (a -> Maybe a) -> (Maybe a) -> EffectFnAff (Maybe String)

-- | Close a file stream
close :: Stream -> Aff Unit
close = fromEffectFnAff <<< close_
foreign import close_ :: Stream -> EffectFnAff Unit

seek :: Stream -> Int -> Aff Unit
seek s position = fromEffectFnAff $ seek_ s position
foreign import seek_ :: Stream -> Int -> EffectFnAff Unit
