module PhantomJS.Page
  ( RenderFormat(..)
  , RenderSettings
  , jpeg
  , png
  , Page
  , createPage
  , customHeaders
  , open
  , render
  , injectJs
  , evaluate
  ) where

import Prelude (class Show, show)
import Control.Monad.Aff (Aff)
import Data.Tuple (Tuple)
import Data.StrMap (StrMap, fromFoldable)
import Data.Foldable (class Foldable)

type URL = String
type FilePath = String
type RenderQuality = Int

-- | The type of image format when rendering a screenshot
data RenderFormat
  = PDF
  | PNG
  | JPEG
  | BMP
  | PPM
  | GIF

instance showRenderFormat :: Show RenderFormat where
  show PDF = "pdf"
  show PNG = "png"
  show JPEG = "jpg"
  show BMP = "bmp"
  show PPM = "ppm"
  show GIF = "gif"

-- | The type and quality of a rendered screenshot
newtype RenderSettings
  = RenderSettings
  { format :: RenderFormat
  , quality :: RenderQuality }

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
foreign import data Page :: *

foreign import createPage_ :: forall e. Aff (| e) Page

-- | Creates a new page context.
createPage :: forall e. Aff e Page
createPage = createPage_


foreign import customHeaders_ :: forall e. Page -> StrMap String -> Aff (| e) Page

-- | Sets custom headers on a page context.  These headers will persist
-- | for the life of the context.
customHeaders :: forall e f. (Foldable f) => Page -> f (Tuple String String) -> Aff e Page
customHeaders page headers = customHeaders_ page (fromFoldable headers)


foreign import open_ :: forall e. Page -> URL -> Aff (| e) Page

-- | Opens a URL in a page context.
open :: forall e. Page -> URL -> Aff e Page
open = open_


foreign import render_ :: forall e. Page -> FilePath -> String -> RenderQuality -> Aff (| e) Page

-- | Renders a screenshot of the given page.
render :: forall e. Page -> FilePath -> RenderSettings ->  Aff e Page
render page fp (RenderSettings { format : format, quality : quality }) = render_ page fp (show format) quality


foreign import injectJs_ :: forall e. Page -> FilePath -> Aff (| e) Page

-- | Injects a javascript file into a page.
injectJs :: forall e. Page -> FilePath -> Aff e Page
injectJs = injectJs_


foreign import evaluate_ :: forall e a. Page -> String -> Aff (| e) a

-- | Evaluates a specific function on the window object of the page.
-- | When using this function you will need to add a type annotation so
-- | PureScript knows what type the native javascript will return, e.g.
-- |
-- | `result <- evaluate page "file.js" :: forall e. Aff e (Array String)`
evaluate :: forall e a. Page -> String -> Aff e a
evaluate = evaluate_
