module PhantomJS.File where

import Prelude
import Data.Function.Uncurried (Fn4, Fn3, runFn4, runFn3)
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)

type Charset = String
type FilePath = String

newtype FileMode = FileMode String

-- instance showFilemode :: Show FileMode where
--   show R = "r"
--   show W = "w"
--   show A = "a/+"
--   show B = "b"

newtype FileSettings
  = FileSettings
  { mode :: FileMode
  -- http://www.iana.org/assignments/character-sets/character-sets.xhtml
  , charset :: String }

forWritingIn :: Charset -> FileSettings
forWritingIn charset =
  FileSettings
  { mode : FileMode "w"
  , charset : charset
  }

forAppendingIn :: Charset -> FileSettings
forAppendingIn charset =
  FileSettings
  { mode : FileMode "a/+"
  , charset : charset
  }

foreign import data PHANTOMFS :: !

foreign import data FileStream :: *

type PhantomEff e a = Eff ( phantomfs :: PHANTOMFS | e ) a
type PhantomAff e a = Aff ( phantomfs :: PHANTOMFS | e ) a

foreign import openStream_ ::
  forall e.
  Fn4
  (FileStream -> PhantomEff e Unit)
  (Error -> PhantomEff e Unit)
  FilePath
  FileSettings
  (PhantomEff e Unit)

foreign import writeStream_ ::
  forall e.
  Fn4
  (FileStream -> PhantomEff e Unit)
  (Error -> PhantomEff e Unit)
  FileStream
  String
  (PhantomEff e Unit)

foreign import closeStream_ ::
  forall e.
  Fn3
  (Unit -> PhantomEff e Unit)
  (Error -> PhantomEff e Unit)
  FileStream
  (PhantomEff e Unit)

openStream :: forall e. FilePath -> FileSettings -> PhantomAff e FileStream
openStream fp fs = makeAff (\error success -> runFn4 openStream_ success error fp fs)

writeStream :: forall e. FileStream -> String -> PhantomAff e FileStream
writeStream fs s = makeAff (\error success -> runFn4 writeStream_ success error fs s)

closeStream :: forall e. FileStream -> PhantomAff e Unit
closeStream fs = makeAff (\error success -> runFn3 closeStream_ success error fs)
