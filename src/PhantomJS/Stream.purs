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
  ) where

import Control.Monad.Aff.Compat (EffFnAff(..), fromEffFnAff)
import Data.Foreign (toForeign, Foreign)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Data.TextEncoder (Encoding)
import PhantomJS.File (FileMode, FilePath, PHANTOMJSFS, PhantomFSAff, toForeignFileMode)
import Prelude (class Show, Unit, show, ($), (<<<), (<=<), (=<<))

type ForeignStreamSettings = Foreign
type FSEff e = (phantomjsfs :: PHANTOMJSFS | e)

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
toForeignStreamSettings (StreamSettings { mode : filemode, charset : charset }) =
    toForeign
      { mode : (toForeignFileMode filemode)
      , charset : (show charset) }

-- | Helper for creating a StreamSettings type
withSettings :: FileMode -> Encoding -> StreamSettings
withSettings fm charset =
  StreamSettings
  { mode : fm
  , charset : charset
  }

foreign import data Stream :: Type

foreign import open_ :: forall e. FilePath -> ForeignStreamSettings -> EffFnAff (FSEff e) Stream

foreign import write_ :: forall e.  Stream -> String -> EffFnAff (FSEff e) Unit

foreign import writeLine_ :: forall e.  Stream -> String -> EffFnAff (FSEff e) Unit

foreign import readLine_ :: forall e a.  Stream -> (a -> Maybe a) -> (Maybe a) -> EffFnAff (FSEff e) (Maybe String)

foreign import close_ :: forall e. Stream -> EffFnAff (FSEff e) Unit

foreign import seek_ :: forall e. Stream -> Int -> EffFnAff (FSEff e) Unit

-- | Open a file stream
open :: forall e. FilePath -> StreamSettings -> PhantomFSAff e Stream
open fp fs = fromEffFnAff $ open_ fp (toForeignStreamSettings fs)

-- | Write to a file stream
write :: forall e. Stream -> String -> PhantomFSAff e Unit
write s t = fromEffFnAff $ write_ s t

-- | Write a line to a file stream
writeLine :: forall e. Stream -> String -> PhantomFSAff e Unit
writeLine s t = fromEffFnAff $ writeLine_ s t 

-- | Read a line from a file stream
readLine :: forall e. Stream -> PhantomFSAff e (Maybe String)
readLine stream = fromEffFnAff $ readLine_ stream Just Nothing

-- | Close a file stream
close :: forall e. Stream -> PhantomFSAff e Unit
close = fromEffFnAff <<< close_

seek :: forall e. Stream -> Int -> PhantomFSAff e Unit
seek s position = fromEffFnAff $ seek_ s position
