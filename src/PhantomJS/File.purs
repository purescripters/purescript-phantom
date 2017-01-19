module PhantomJS.File where

import Prelude (Unit, class Eq, class Show)
import Data.Function.Uncurried (Fn2, runFn2)
import Control.Monad.Aff (Aff)
import Data.Foreign (toForeign)
import Data.Foreign.Class (class AsForeign, write)
import Data.Generic (class Generic)
import Data.Generic.Rep.Show (genericShow)

type Charset = String
type FilePath = String

data FileMode
  = R
  | W
  | A
  | B

derive instance eqFileMode :: Eq FileMode
derive instance genericFileMode :: Generic FileMode
instance showFileMode :: Show FileMode where
  show x = genericShow x

instance foreignFileMode :: AsForeign FileMode where
  write R = toForeign "r"
  write W = toForeign "w"
  write A = toForeign "a/+"
  write B = toForeign "b"


newtype FileSettings
  = FileSettings
  { mode :: FileMode
  -- http://www.iana.org/assignments/character-sets/character-sets.xhtml
  , charset :: String }

derive instance asForeignFileSettings :: AsForeign FileSettings

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

foreign import openStream_ :: forall e. Fn2 FilePath FileSettings (PhantomAff e FileStream)

foreign import writeStream_ :: forall e.  Fn2 FileStream String (PhantomAff e FileStream)

foreign import closeStream_ :: forall e. FileStream -> (PhantomAff e Unit)

openStream :: forall e. FilePath -> FileSettings -> PhantomAff e FileStream
openStream fp fs = runFn2 openStream_ fp (write fs)

writeStream :: forall e. FileStream -> String -> PhantomAff e FileStream
writeStream = runFn2 writeStream_

closeStream :: forall e. FileStream -> PhantomAff e Unit
closeStream = closeStream_
