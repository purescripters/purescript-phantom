module PhantomJS.Page
  ( RenderFormat(..)
  , RenderSettings
  , jpeg
  , png
  , Page
  , createPage
  , customHeadersRaw
  , open
  , render
  , injectJs
  , evaluate
  ) where

import Prelude (class Show, show, class Eq, (<<<))
import Control.Monad.Aff (Aff)
import Data.Tuple (Tuple)
import Data.StrMap (StrMap, fromFoldable)
import Data.Foldable (class Foldable)
import PhantomJS.Phantom (PHANTOMJS)
import Data.Foreign (toForeign, Foreign)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Control.Monad.Eff (kind Effect)

type URL = String
type FilePath = String
type RenderQuality = Int
type PhantomAff e a = Aff (phantomjs :: PHANTOMJS | e) a
type ForeignRenderSettings = Foreign

-- | The type of image format when rendering a screenshot
data RenderFormat
  = PDF
  | PNG
  | JPEG
  | BMP
  | PPM
  | GIF

derive instance eqRenderFormat :: Eq RenderFormat

instance showRenderFormat :: Show RenderFormat where
  show PDF = "pdf"
  show PNG = "png"
  show JPEG = "jpg"
  show BMP = "bmp"
  show PPM = "ppm"
  show GIF = "gif"

toForeignRenderFormat :: RenderFormat -> Foreign
toForeignRenderFormat = toForeign <<< show

-- | The type and quality of a rendered screenshot
newtype RenderSettings
  = RenderSettings
  { format :: RenderFormat
  , quality :: RenderQuality }

derive instance genericRenderSettings :: Generic RenderSettings _
derive instance eqRenderSettings :: Eq RenderSettings

instance showRenderSettings :: Show RenderSettings where
  show = genericShow

toForeignRenderSettings :: RenderSettings -> Foreign
toForeignRenderSettings (RenderSettings { format : format, quality : quality }) =
    toForeign
      { format : (toForeignRenderFormat format)
      , quality : quality }

-- | Predefined setting for rendering screenshot as jpeg
jpeg :: RenderSettings
jpeg
  = RenderSettings
  { format : JPEG
  , quality : 100 }


-- | Predefined setting for rendering screenshot as png
png :: RenderSettings
png
  = RenderSettings
  { format : PNG
  , quality : 100 }

-- | The type of a PhantomJS page context.
foreign import data Page :: Type

foreign import createPage_ :: forall e. PhantomAff e Page

-- | Creates a new page context.
createPage :: forall e. PhantomAff e Page
createPage = createPage_


foreign import customHeaders_ :: forall e. Page -> StrMap String -> PhantomAff e Page

-- | Sets custom headers on a page context.  These headers will persist
-- | for the life of the context.
customHeadersRaw :: forall e f. (Foldable f) => Page -> f (Tuple String String) -> PhantomAff e Page
customHeadersRaw page headers = customHeaders_ page (fromFoldable headers)


foreign import open_ :: forall e. Page -> URL -> PhantomAff e Page

-- | Opens a URL in a page context.
open :: forall e. Page -> URL -> PhantomAff e Page
open = open_


foreign import render_ :: forall e. Page -> FilePath -> ForeignRenderSettings -> PhantomAff e Page

-- | Renders a screenshot of the given page.
render :: forall e. Page -> FilePath -> RenderSettings ->  PhantomAff e Page
render page fp rs = render_ page fp (toForeignRenderSettings rs)


foreign import injectJs_ :: forall e. Page -> FilePath -> PhantomAff e Page

-- | Injects a javascript file into a page.
injectJs :: forall e. Page -> FilePath -> PhantomAff e Page
injectJs = injectJs_


foreign import evaluate_ :: forall e a. Page -> String -> PhantomAff e a

-- | Evaluates a specific function on the window object of the page.
-- | When using this function you will need to add a type annotation so
-- | PureScript knows what type the native javascript will return, e.g.
-- |
-- | `result <- evaluate page "file.js" :: forall e. Aff e (Array String)`
evaluate :: forall e a. Page -> String -> PhantomAff e a
evaluate = evaluate_
