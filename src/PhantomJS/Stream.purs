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
  ) where

import Prelude (Unit, class Show)
import Data.Foreign (toForeign, Foreign)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import PhantomJS.File (FileMode, Charset, FilePath, PhantomFSAff, toForeignFileMode)

type ForeignStreamSettings = Foreign

-- http://stackoverflow.com/questions/8509339/what-is-the-most-common-encoding-of-each-language
-- http://www.iana.org/assignments/character-sets/character-sets.xhtml
-- | The filemode and character set settings needed to open a stream.
newtype StreamSettings = StreamSettings
  { mode :: FileMode
  , charset :: Charset
  }

derive instance genericStreamSettings :: Generic StreamSettings _
instance showStreamSettings :: Show StreamSettings where
  show = genericShow

toForeignStreamSettings :: StreamSettings -> Foreign
toForeignStreamSettings (StreamSettings { mode : filemode, charset : charset }) =
    toForeign
      { mode : (toForeignFileMode filemode)
      , charset : (toForeign charset) }

-- | Helper for creating a StreamSettings type
withSettings :: FileMode -> Charset -> StreamSettings
withSettings fm charset =
  StreamSettings
  { mode : fm
  , charset : charset
  }

foreign import data Stream :: Type

foreign import open_ :: forall e. FilePath -> ForeignStreamSettings -> PhantomFSAff e Stream

foreign import write_ :: forall e.  Stream -> String -> PhantomFSAff e Stream

foreign import writeLine_ :: forall e.  Stream -> String -> PhantomFSAff e Stream

foreign import readLine_ :: forall e a.  Stream -> (a -> Maybe a) -> (Maybe a) -> PhantomFSAff e (Maybe String)

foreign import close_ :: forall e. Stream -> PhantomFSAff e Unit

-- | Open a file stream
open :: forall e. FilePath -> StreamSettings -> PhantomFSAff e Stream
open fp fs = open_ fp (toForeignStreamSettings fs)

-- | Write to a file stream
write :: forall e. Stream -> String -> PhantomFSAff e Stream
write = write_

-- | Write a line to a file stream
writeLine :: forall e. Stream -> String -> PhantomFSAff e Stream
writeLine = writeLine_

-- | Read a line from a file stream
readLine :: forall e. Stream -> PhantomFSAff e (Maybe String)
readLine stream = readLine_ stream Just Nothing

-- | Close a file stream
close :: forall e. Stream -> PhantomFSAff e Unit
close = close_
