-- | This module defines types and functions for working with files.
-- | The following file modes are currently available:
-- |
-- | R  - read       - don't create file if not exists
-- | RW - read+write - don't create fuke if not exists, truncate existing text
-- | W  - write      - create if not exists, truncate existing text
-- | A  - append     - create if not exists, append to existing text

module PhantomJS.File
  ( FileMode(..)
  , Charset
  , FilePath
  , PHANTOMJSFS
  , PhantomFSAff
  , exists
  , remove
  , write
  , read
  , lastModified
  , toForeignFileMode
  ) where

import Control.Monad.Aff (Aff)
import Control.Monad.Aff.Compat (EffFnAff(..), fromEffFnAff)
import Control.Monad.Eff (kind Effect)
import Data.Foreign (toForeign, Foreign)
import Data.Generic.Rep (class Generic)
import Data.Time.Duration (Milliseconds)
import Prelude (class Eq, class Show, Unit, show, ($), (<<<))

type Charset = String
type FilePath = String
type FileContent = String
type FSEff e = (phantomjsfs :: PHANTOMJSFS | e)
type PhantomFSAff e a = Aff (phantomjsfs :: PHANTOMJSFS | e) a
type ForeignFileMode = Foreign

-- http://phantomjs.org/api/fs/method/open.html
-- Doesn't look like the + does anything.
-- | File modes for opening a file.  Read, Write, Append, Read-Write
data FileMode = R | W | A | RW

derive instance genericFileMode :: Generic FileMode _
derive instance eqFileMode :: Eq FileMode

instance showFileMode :: Show FileMode where
  show R = "r"   -- read         -   (don't create if not exists)
  show RW = "rw" -- read + write -   (don't create if not exists, overwrite existing)
  show W = "w"   -- write        -   (create if not exists, overwrite existing)
  show A = "a"   -- append       -   (create if not exists, append to file)

-- | Used to convert a FileMode to a foreign type
-- | that can be passed into native phantomjs functions.
toForeignFileMode :: FileMode -> Foreign
toForeignFileMode = toForeign <<< show

foreign import data PHANTOMJSFS :: Effect

foreign import exists_ :: forall e. FilePath -> EffFnAff (FSEff e) Boolean

foreign import remove_ :: forall e. FilePath -> EffFnAff (FSEff e) Unit

foreign import write_ :: forall e. FilePath -> FileContent -> ForeignFileMode -> EffFnAff (FSEff e) Unit

foreign import read_ :: forall e. FilePath -> EffFnAff (FSEff e) String

foreign import lastModified_ :: forall e. FilePath -> EffFnAff (FSEff e) Milliseconds

-- Deletes a file
remove :: forall e. FilePath -> Aff (FSEff e) Unit
remove = fromEffFnAff <<< remove_

-- Checks if a file exists
exists :: forall e. FilePath -> Aff (FSEff e) Boolean
exists = fromEffFnAff <<< exists_

-- Writes to a file
write :: forall e. FilePath -> FileContent -> FileMode -> Aff (FSEff e) Unit
write fp c fm = fromEffFnAff $ write_ fp c (toForeignFileMode fm)

-- Reads from a file
read :: forall e. FilePath -> Aff (FSEff e) String
read = fromEffFnAff <<< read_

-- Returns the last modified date of a file in milliseconds.  If the file
-- doesn't exist, an error is thrown.
lastModified :: forall e. FilePath -> Aff (FSEff e) Milliseconds
lastModified = fromEffFnAff <<< lastModified_
