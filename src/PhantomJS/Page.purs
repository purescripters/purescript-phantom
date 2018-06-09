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

import Data.Foldable (class Foldable, foldMap)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable)
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff, Fiber, forkAff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (unsafeToForeign, Foreign)

type URL = String
type FilePath = String
type RenderQuality = Int

-- | Holds information related to a stack trace
newtype StackInfo = StackInfo
  { line :: Int
  , file :: String
  , function :: Maybe String
  }

derive instance genericStackInfo :: Generic StackInfo _
derive instance eqStackInfo :: Eq StackInfo
instance showStackInfo :: Show StackInfo where
  show = genericShow

-- | The type for errors on a page
newtype PageError = PageError
  { message :: String
  , trace :: Array StackInfo
  }

derive instance genericPageError :: Generic PageError _
derive instance eqPageError :: Eq PageError
instance showPageError :: Show PageError where
  show = genericShow

-- | The type of image format when rendering a screenshot
data RenderFormat
  = PDF
  | PNG
  | JPEG
  | BMP
  | PPM
  | GIF

derive instance eqRenderFormat :: Eq RenderFormat
derive instance genericRenderFormat :: Generic RenderFormat _
instance showRenderFormat :: Show RenderFormat where
  show = genericShow

-- | Used to convert RenderFormat to a foreign type
-- | that can be passed into native phantomjs functions.
toForeignRenderFormat :: RenderFormat -> Foreign
toForeignRenderFormat = unsafeToForeign <<< case _ of
  PDF -> "pdf"
  PNG -> "png"
  JPEG -> "jpg"
  BMP -> "bmp"
  PPM -> "ppm"
  GIF -> "gif"

-- | The type and quality of a rendered screenshot
newtype RenderSettings = RenderSettings
  { format :: RenderFormat
  , quality :: RenderQuality
  }

derive instance genericRenderSettings :: Generic RenderSettings _
derive instance eqRenderSettings :: Eq RenderSettings
instance showRenderSettings :: Show RenderSettings where
  show = genericShow

-- | Represents an HTTP network request
newtype PhantomRequest = PhantomRequest
  { url :: String
  , method :: String
  , postData :: Nullable String
  }

derive instance genericPhantomRequest :: Generic PhantomRequest _
derive instance eqPhantomRequest :: Eq PhantomRequest
instance showPhantomRequest :: Show PhantomRequest where
  show = genericShow

-- | Used to convert RenderSettings to a foreign type
-- | that can be passed into native phantomjs functions.
toForeignRenderSettings :: RenderSettings -> Foreign
toForeignRenderSettings (RenderSettings { format, quality }) =
  unsafeToForeign
    { format: toForeignRenderFormat format
    , quality: quality
    }

-- | Predefined setting for rendering screenshot as jpeg
jpeg :: RenderSettings
jpeg = RenderSettings
  { format: JPEG
  , quality: 100
  }

-- | Predefined setting for rendering screenshot as png
png :: RenderSettings
png = RenderSettings
  { format: PNG
  , quality: 100
  }

-- | The type of a PhantomJS page context.
foreign import data Page :: Type

-- | Creates a new page context.
createPage :: Aff Page
createPage = fromEffectFnAff createPage_
foreign import createPage_ :: EffectFnAff Page

-- | Sets custom headers on a page context.  These headers will persist
-- | for the life of the context.
customHeadersRaw :: forall f. (Foldable f) => Page -> f (Tuple String String) -> Aff Unit
customHeadersRaw page headers = fromEffectFnAff $ customHeaders_ page (foldMap g headers)
  where
  g :: Tuple String String -> Array { key :: String, value :: String }
  g (Tuple key value) = [ { key, value } ]
foreign import customHeaders_ :: Page -> Array { key :: String, value :: String } -> EffectFnAff Unit

-- | Opens a URL in a page context.
open :: Page -> URL -> Aff Unit
open p u = fromEffectFnAff $ open_ p u
foreign import open_ :: Page -> URL -> EffectFnAff Unit

-- | Renders a screenshot of the given page.
render :: Page -> FilePath -> RenderSettings -> Aff Unit
render page fp rs = fromEffectFnAff $ render_ page fp (toForeignRenderSettings rs)
foreign import render_ :: Page -> FilePath -> Foreign -> EffectFnAff Unit

-- | Injects a javascript file into a page.
injectJs :: Page -> FilePath -> Aff Unit
injectJs page fp = fromEffectFnAff $ injectJs_ page fp
foreign import injectJs_ :: Page -> FilePath -> EffectFnAff Unit

-- | Evaluates a specific function on the window object of the page.
evaluate :: Page -> String -> Aff Foreign
evaluate page fp = fromEffectFnAff $ evaluate_ page fp
foreign import evaluate_ :: Page -> String -> EffectFnAff Foreign

-- | Intercept a single network request for a page
onResourceRequested :: Page -> Aff PhantomRequest
onResourceRequested page = fromEffectFnAff $ onResourceRequested_ page
foreign import onResourceRequested_ :: Page -> EffectFnAff PhantomRequest

-- | Intercept a page's network requests for a certain number of milliseconds
-- |
-- | `
-- | synchronousRequests <- onResourceRequestedFor page 10000
-- | requestsFiber <- forkAff $ onResourceRequestedFor page 800
-- | -- Do some more synchronous stuff...
-- | request <- try (joinFiber requestsFiber)
-- | `
onResourceRequestedFor :: Page -> Int -> Aff (Array PhantomRequest)
onResourceRequestedFor page time =  fromEffectFnAff $ onResourceRequestedFor_ page time
foreign import onResourceRequestedFor_ :: Page -> Int -> EffectFnAff (Array PhantomRequest)

-- | Prevent the default console error logging, and store errors for later retrieval.
-- | Return a fiber which can be killed to stop the silence and restore the default
-- | functionality.
silencePageErrors :: Page -> Aff (Fiber Unit)
silencePageErrors page = forkAff $ fromEffectFnAff $ silencePageErrors_ page
foreign import silencePageErrors_ :: Page -> EffectFnAff Unit


-- | Clear a page's stored errors
clearPageErrors :: Page -> Aff Unit
clearPageErrors page = fromEffectFnAff $ clearPageErrors_ page
foreign import clearPageErrors_ :: Page -> EffectFnAff Unit

-- | Get page errors that have been stored after running silencePageErrors
getSilencedErrors :: Page -> Aff (Array PageError)
getSilencedErrors page = fromEffectFnAff $ runFn3 getSilencedErrors_ page Just Nothing
foreign import getSilencedErrors_ :: forall a. Fn3 Page (a -> Maybe a) (Maybe a) (EffectFnAff (Array PageError))

-- | Function to wait a certain number of milliseconds
wait :: Int -> Aff Unit
wait time = fromEffectFnAff $ waitImpl time
foreign import waitImpl :: Int -> EffectFnAff Unit
