module PhantomJS.File
  ( FileMode(..)
  , Charset
  , FilePath
  , PHANTOMJSFS
  , PhantomFSAff
  , exists
  , remove
  , lastModified
  ) where

import Prelude (Unit, class Eq,class Show, show, (<<<))
import Control.Monad.Aff (Aff)
import Data.Foreign (toForeign, Foreign)
import Data.Foreign.Class as FC
import Data.Foreign.Class (class AsForeign)
import Data.Generic.Rep (class Generic)
import Data.Time.Duration (Milliseconds)

type Charset = String
type FilePath = String
type PhantomFSAff e a = Aff ( phantomjsfs :: PHANTOMJSFS | e ) a
type ForeignFileMode = Foreign

-- http://phantomjs.org/api/fs/method/open.html
-- Doesn't look like the + does anything.
-- | File modes for opening a file.  Read, Write, Append, Read-Write
data FileMode = R | W | A | RW

derive instance genericFileMode :: Generic FileMode _
derive instance eqFileMode :: Eq FileMode

instance showFileMode :: Show FileMode where
  show R = "r"   -- read         -   (don't create if not exists)
  show RW = "rw" -- read + write -   (don't create if not exists, append to file)
  show W = "w"   -- write        -  (create if not exists, overwrite existing)
  show A = "a"   -- append       -  (create if not exists, append to file)

instance foreignFileMode :: AsForeign FileMode where
  write = toForeign <<< show

foreign import data PHANTOMJSFS :: !

foreign import exists_ :: forall e. FilePath -> PhantomFSAff e Boolean

foreign import remove_ :: forall e. FilePath -> PhantomFSAff e Unit

foreign import write_ :: forall e. FilePath -> String -> ForeignFileMode -> PhantomFSAff e Unit

foreign import lastModified_ :: forall e. FilePath -> PhantomFSAff e Milliseconds

-- Deletes a file
remove :: forall e. FilePath -> PhantomFSAff e Unit
remove = remove_

-- Checks if a file exists
exists :: forall e. FilePath -> PhantomFSAff e Boolean
exists = exists_

-- Writes to a file
write :: forall e. FilePath -> String -> FileMode -> PhantomFSAff e Unit
write fp c fm = write_ fp c (FC.write fm)

-- Returns the last modified date of a file in milliseconds.  If the file
-- doesn't exist, an error is thrown.
lastModified :: forall e. FilePath -> PhantomFSAff e Milliseconds
lastModified fp = lastModified_ fp
