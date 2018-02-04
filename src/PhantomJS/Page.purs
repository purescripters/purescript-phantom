module PhantomJS.Page
  ( RenderFormat(..)
  , RenderSettings
  , PageError
  , StackInfo
  , jpeg
  , png
  , Page
  , createPage
  , customHeadersRaw
  , open
  , render
  , injectJs
  , evaluate
  , onResourceRequested
  , onResourceRequestedFor
  , silencePageErrors
  , getSilencedErrors
  , clearPageErrors
  , PhantomRequest(..)
  , wait
  ) where

import Prelude

import Control.Monad.Aff (Aff, Fiber, forkAff)
import Control.Monad.Aff.Compat (EffFnAff, fromEffFnAff)
import Control.Monad.Eff (kind Effect)
import Data.Foldable (class Foldable)
import Data.Foreign (toForeign, Foreign)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable)
import Data.StrMap (StrMap, fromFoldable)
import Data.Tuple (Tuple)
import PhantomJS.Phantom (PHANTOMJS)

type URL = String
type FilePath = String
type RenderQuality = Int
type PhantomAff e a = Aff (phantomjs :: PHANTOMJS | e) a
type EffPhantomAff e a = EffFnAff (phantomjs :: PHANTOMJS | e) a

-- | Holds information related to a stack trace
newtype StackInfo = StackInfo {
  line :: Int,
  file :: String,
  function :: Maybe String
}

derive instance genericStackInfo :: Generic StackInfo _
derive instance eqStackInfo :: Eq StackInfo
instance showStackInfo :: Show StackInfo where
  show = genericShow


-- | The type for errors on a page
newtype PageError = PageError {
  message :: String,
  trace :: Array StackInfo
}

derive instance genericPageError :: Generic PageError _
derive instance eqPageError :: Eq PageError
instance showPageError :: Show PageError where
  show = genericShow

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

-- | Used to convert RenderFormat to a foreign type
-- | that can be passed into native phantomjs functions.
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


-- | Represents an HTTP network request
newtype PhantomRequest
  = PhantomRequest
  { url :: String
  , method :: String
  , postData :: Nullable String }

derive instance genericPhantomRequest :: Generic PhantomRequest _
derive instance eqPhantomRequest :: Eq PhantomRequest
instance showPhantomRequest :: Show PhantomRequest where
  show = genericShow


-- | Used to convert RenderSettings to a foreign type
-- | that can be passed into native phantomjs functions.
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

foreign import createPage_ :: forall e. EffPhantomAff e Page

-- | Creates a new page context.
createPage :: forall e. PhantomAff e Page
createPage = fromEffFnAff createPage_


foreign import customHeaders_ :: forall e. Page -> StrMap String -> EffPhantomAff e Unit

-- | Sets custom headers on a page context.  These headers will persist
-- | for the life of the context.
customHeadersRaw :: forall e f. (Foldable f) => Page -> f (Tuple String String) -> PhantomAff e Unit
customHeadersRaw page headers = fromEffFnAff $ customHeaders_ page (fromFoldable headers)


foreign import open_ :: forall e. Page -> URL -> EffPhantomAff e Unit

-- | Opens a URL in a page context.
open :: forall e. Page -> URL -> PhantomAff e Unit
open p u = fromEffFnAff $ open_ p u


foreign import render_ :: forall e. Page -> FilePath -> ForeignRenderSettings -> EffPhantomAff e Unit

-- | Renders a screenshot of the given page.
render :: forall e. Page -> FilePath -> RenderSettings ->  PhantomAff e Unit
render page fp rs = fromEffFnAff $ render_ page fp (toForeignRenderSettings rs)


foreign import injectJs_ :: forall e. Page -> FilePath -> EffPhantomAff e Unit

-- | Injects a javascript file into a page.
injectJs :: forall e. Page -> FilePath -> PhantomAff e Unit
injectJs page fp = fromEffFnAff $ injectJs_ page fp


foreign import evaluate_ :: forall e a. Page -> String -> EffPhantomAff e a

-- | Evaluates a specific function on the window object of the page.
-- | When using this function you will need to add a type annotation so
-- | PureScript knows what type the native javascript will return, e.g.
-- |
-- | `result <- evaluate page "file.js" :: forall e. Aff e (Array String)`
evaluate :: forall e a. Page -> String -> PhantomAff e a
evaluate page fp = fromEffFnAff $ evaluate_ page fp


foreign import onResourceRequested_ :: forall e a. Page -> EffPhantomAff e PhantomRequest

-- | Intercept a single network request for a page
onResourceRequested :: forall e a. Page -> PhantomAff e PhantomRequest
onResourceRequested page = fromEffFnAff $ onResourceRequested_ page


foreign import onResourceRequestedFor_ :: forall e a. Page -> Int -> EffPhantomAff e (Array PhantomRequest)

-- | Intercept a page's network requests for a certain number of milliseconds
-- |
-- | `
-- | synchronousRequests <- onResourceRequestedFor page 10000
-- | requestsFiber <- forkAff $ onResourceRequestedFor page 800
-- | -- Do some more synchronous stuff...
-- | request <- try (joinFiber requestsFiber)
-- | `
onResourceRequestedFor :: forall e a. Page -> Int -> PhantomAff e (Array PhantomRequest)
onResourceRequestedFor page time =  fromEffFnAff $ onResourceRequestedFor_ page time


foreign import silencePageErrors_ :: forall e a. Page -> EffPhantomAff e Unit

-- | Prevent the default console error logging, and store errors for later retrieval.
-- | Return a fiber which can be killed to stop the silence and restore the default
-- | functionality.
silencePageErrors :: forall e a. Page -> PhantomAff e (Fiber (phantomjs :: PHANTOMJS | e) Unit)
silencePageErrors page = forkAff $ fromEffFnAff $ silencePageErrors_ page

foreign import clearPageErrors_ :: forall e a. Page -> EffPhantomAff e Unit

-- | Clear a page's stored errors
clearPageErrors :: forall e. Page -> PhantomAff e Unit
clearPageErrors page = fromEffFnAff $ clearPageErrors_ page


foreign import getSilencedErrors_ :: forall e a. Fn3 Page (a -> Maybe a) (Maybe a) (EffPhantomAff e (Array PageError))

-- | Get page errors that have been stored after running silencePageErrors
getSilencedErrors :: forall e. Page -> PhantomAff e (Array PageError)
getSilencedErrors page = fromEffFnAff $ runFn3 getSilencedErrors_ page Just Nothing


foreign import waitImpl :: forall e. Int -> EffPhantomAff e Unit

-- | Function to wait a certain number of milliseconds
wait :: forall e. Int -> PhantomAff e Unit
wait time = fromEffFnAff $ waitImpl time