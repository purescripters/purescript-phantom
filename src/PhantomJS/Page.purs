module PhantomJS.Page
  ( RenderFormat(..)
  , RenderSettings
  , jpeg
  , Page
  , createPage
  , hPair
  , customHeaders
  , open
  , render
  , injectJs
  , evaluate
  ) where

import Prelude
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Data.Tuple (Tuple(..))
import Data.StrMap (StrMap, fromFoldable)
import Data.Foldable (class Foldable)

type URL = String
type Filename = String


data RenderFormat
  = PDF
  | PNG
  | JPEG
  | BMP
  | PPM
  | GIF


newtype RenderSettings
  = RenderSettings
  { format :: RenderFormat
  , quality :: Int }


jpeg :: RenderSettings
jpeg
  = RenderSettings
  { format : JPEG
  , quality : 100 }


foreign import data Page :: *


foreign import createPage_ :: forall e. (Page -> Eff e Unit) -> Eff e Unit

createPage :: forall e. Aff e Page
createPage = makeAff (\error success -> createPage_ success)

-- | Just so consumers don't have to impore Tuple themselves...
hPair :: String -> String -> Tuple String String
hPair = Tuple

foreign import customHeaders_ :: forall e.
  (Page -> Eff e Unit) ->
  (Error -> Eff e Unit) ->
  Page ->
  StrMap String ->
  Eff e Unit

customHeaders :: forall e f. (Foldable f) => Page -> f (Tuple String String) -> Aff e Page
customHeaders page headers =
  makeAff (\error success ->
    customHeaders_ success error page (fromFoldable headers)
  )

foreign import open_ :: forall e.
  (Page -> Eff e Unit) ->
  (Error -> Eff e Unit) ->
  Page ->
  URL ->
  Eff e Unit

open :: forall e. Page -> URL -> Aff e Page
open p url = makeAff (\error success -> open_ success error p url)


foreign import render_ :: forall e.
  (Page -> Eff e Unit) ->
  Page ->
  Filename ->
  RenderSettings ->
  Eff e Unit

render :: forall e. Page -> Filename -> RenderSettings ->  Aff e Page
render p filename rs = makeAff (\error success -> render_ success p filename rs)


foreign import injectJs_ :: forall e.
  (Page -> Eff e Unit) ->
  (Error -> Eff e Unit) ->
  Page ->
  Filename ->
  Eff e Unit

injectJs :: forall e. Page -> Filename -> Aff e Page
injectJs p filename = makeAff (\error success -> injectJs_ success error p filename)


foreign import evaluate_ :: forall e a.
  (a -> Eff e Unit) ->
  (Error -> Eff e Unit) ->
  Page ->
  String ->
  Eff e Unit

evaluate :: forall e a. Page -> String -> Aff e a
evaluate p fnName = makeAff (\error success -> evaluate_ success error p fnName)
