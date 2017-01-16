module PhantomJS.Page where

import Prelude
import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import PhantomJS.Phantom (PHANTOMJS)

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


foreign import open_ :: forall e.
  (Page -> Eff e Unit) ->
  Page ->
  URL ->
  Eff e Unit

open :: forall e. Page -> URL -> Aff e Page
open p url = makeAff (\error success -> open_ success p url)


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
  Page ->
  Filename ->
  Eff e Unit

injectJs :: forall e. Page -> Filename -> Aff e Page
injectJs p filename = makeAff (\error success -> injectJs_ success p filename)


foreign import evaluate_ :: forall e.
  (Array String -> Eff e Unit) ->
  Page ->
  String ->
  Eff e Unit

evaluate :: forall e. Page -> String -> Aff e (Array String)
evaluate p fnName = makeAff (\error success -> evaluate_ success p fnName)
