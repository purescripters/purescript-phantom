module PhantomJS.Stream where

import Prelude (pure, Unit, class Eq, (<>), class Show, show, (<<<), class Monad, class Applicative, (>>=))
import Data.Monoid (class Monoid, mempty)
import Control.Monad.Aff (Aff)
import Data.Foreign (toForeign, Foreign)
import Data.Foreign.Class as FC
import Data.Foreign.Class (class AsForeign)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..), maybe)

type Charset = String
type FilePath = String
type ForeignStreamSettings = Foreign

-- http://phantomjs.org/api/fs/method/open.html
-- Doesn't look like the + does anything.
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

-- http://www.iana.org/assignments/character-sets/character-sets.xhtml
newtype StreamSettings = StreamSettings
  { mode :: FileMode
  , charset :: String
  }

derive instance genericStreamSettings :: Generic StreamSettings _
instance showStreamSettings :: Show StreamSettings where
  show = genericShow

instance asForeignStreamSettings :: AsForeign StreamSettings where
  write (StreamSettings { mode : filemode, charset : charset }) =
    toForeign
      { mode : (FC.write filemode)
      , charset : (FC.write charset) }

withSettings :: FileMode -> Charset -> StreamSettings
withSettings fm charset =
  StreamSettings
  { mode : fm
  , charset : charset
  }
  
foreign import data PHANTOMJSFS :: !

foreign import data Stream :: *

type PhantomAff e a = Aff ( phantomjsfs :: PHANTOMJSFS | e ) a

foreign import open_ :: forall e. FilePath -> ForeignStreamSettings -> Aff ( phantomjsfs :: PHANTOMJSFS | e ) Stream

foreign import write_ :: forall e.  Stream -> String -> Aff ( phantomjsfs :: PHANTOMJSFS | e ) Stream

foreign import writeLine_ :: forall e.  Stream -> String -> Aff ( phantomjsfs :: PHANTOMJSFS | e ) Stream

foreign import readLine_ :: forall e a.  Stream -> (a -> Maybe a) -> (Maybe a) -> Aff ( phantomjsfs :: PHANTOMJSFS | e ) (Maybe String)

foreign import close_ :: forall e. Stream -> (Aff ( phantomjsfs :: PHANTOMJSFS | e ) Unit)

open :: forall e. FilePath -> StreamSettings -> Aff ( phantomjsfs :: PHANTOMJSFS | e ) Stream
open fp fs = open_ fp (FC.write fs)

write :: forall e. Stream -> String -> Aff ( phantomjsfs :: PHANTOMJSFS | e ) Stream
write = write_

writeLine :: forall e. Stream -> String -> Aff ( phantomjsfs :: PHANTOMJSFS | e ) Stream
writeLine = writeLine_

readLine :: forall e. Stream -> Aff ( phantomjsfs :: PHANTOMJSFS | e ) (Maybe String)
readLine stream = readLine_ stream Just Nothing


close :: forall e. Stream -> Aff ( phantomjsfs :: PHANTOMJSFS | e ) Unit
close = close_
