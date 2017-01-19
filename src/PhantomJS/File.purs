module PhantomJS.File where

import Prelude (Unit, class Eq, class Show, show, (<<<))
import Data.Function.Uncurried (Fn2, runFn2)
import Control.Monad.Aff (Aff)
import Data.Foreign (toForeign, Foreign)
import Data.Foreign.Class (class AsForeign, write)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)

type Charset = String
type FilePath = String
type ForeignFileSettings = Foreign

data FileMode = R | W | A | B
derive instance genericFileMode :: Generic FileMode _

derive instance eqFileMode :: Eq FileMode

instance showFileMode :: Show FileMode where
  show R = "r"
  show W = "w"
  show A = "a/+"
  show B = "b"

instance foreignFileMode :: AsForeign FileMode where
  write = toForeign <<< show

instance asForeignFileSettings :: AsForeign FileSettings where
  write (FileSettings { mode : filemode, charset : charset }) = toForeign
    { mode : (write filemode)
    , charset : (write charset) }

-- http://www.iana.org/assignments/character-sets/character-sets.xhtml
newtype FileSettings = FileSettings
  { mode :: FileMode
  , charset :: String
  }

derive instance genericFileSettings :: Generic FileSettings _

instance showFileSettings :: Show FileSettings where
  show x = genericShow x


forWritingIn :: Charset -> FileSettings
forWritingIn charset =
  FileSettings
  { mode : W
  , charset : charset
  }

forAppendingIn :: Charset -> FileSettings
forAppendingIn charset =
  FileSettings
  { mode : A
  , charset : charset
  }

foreign import data PHANTOMFS :: !

foreign import data FileStream :: *

type PhantomAff e a = Aff ( phantomfs :: PHANTOMFS | e ) a

foreign import openStream_ :: forall e. Fn2 FilePath ForeignFileSettings (PhantomAff e FileStream)

foreign import writeStream_ :: forall e.  Fn2 FileStream String (PhantomAff e FileStream)

foreign import closeStream_ :: forall e. FileStream -> (PhantomAff e Unit)

openStream :: forall e. FilePath -> FileSettings -> PhantomAff e FileStream
openStream fp fs = runFn2 openStream_ fp (write fs)

writeStream :: forall e. FileStream -> String -> PhantomAff e FileStream
writeStream = runFn2 writeStream_

closeStream :: forall e. FileStream -> PhantomAff e Unit
closeStream = closeStream_
