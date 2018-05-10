-- | This module defines types and functions for working with files.
-- | The following file modes are currently available:
-- |
-- | R  - read       - don't create file if not exists
-- | RW - read+write - don't create fuke if not exists, truncate existing text
-- | W  - write      - create if not exists, truncate existing text
-- | A  - append     - create if not exists, append to existing text

module PhantomJS.File
  ( FileMode(..)
  , FilePath
  , exists
  , remove
  , write
  , read
  , lastModified
  , toForeignFileMode
  ) where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Time.Duration (Milliseconds)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (toForeign, Foreign)

type FilePath = String
type FileContent = String

-- http://phantomjs.org/api/fs/method/open.html
-- Doesn't look like the + does anything.
-- | File modes for opening a file.  Read, Write, Append, Read-Write
data FileMode = R | W | A | RW

derive instance genericFileMode :: Generic FileMode _
derive instance eqFileMode :: Eq FileMode
instance showFileMode :: Show FileMode where
  show = genericShow

-- | Used to convert a FileMode to a foreign type
-- | that can be passed into native phantomjs functions.
toForeignFileMode :: FileMode -> Foreign
toForeignFileMode = toForeign <<< case _ of
  R -> "r"
  W -> "w"
  RW -> "rw"
  A -> "a"

-- | Deletes a file
remove :: FilePath -> Aff Unit
remove = fromEffectFnAff <<< remove_
foreign import remove_ :: FilePath -> EffectFnAff Unit

-- | Checks if a file exists
exists :: FilePath -> Aff Boolean
exists = fromEffectFnAff <<< exists_
foreign import exists_ :: FilePath -> EffectFnAff Boolean

-- | Writes to a file
write :: FilePath -> FileContent -> FileMode -> Aff Unit
write fp c fm = fromEffectFnAff $ write_ fp c (toForeignFileMode fm)
foreign import write_ :: FilePath -> FileContent -> Foreign -> EffectFnAff Unit

-- | Reads from a file
read :: FilePath -> Aff String
read = fromEffectFnAff <<< read_
foreign import read_ :: FilePath -> EffectFnAff String

-- | Returns the last modified date of a file in milliseconds.  If the file
-- | doesn't exist, an error is thrown.
lastModified :: FilePath -> Aff Milliseconds
lastModified = fromEffectFnAff <<< lastModified_
foreign import lastModified_ :: FilePath -> EffectFnAff Milliseconds
