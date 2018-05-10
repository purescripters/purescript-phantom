module PhantomJS.System
  ( os
  , OS
  , foldEnv
  , pid
  , getEnv
  ) where

import Data.Maybe (Maybe(..))
import Effect (Effect)

type OS =
  { architecture :: String
  , name :: String
  , version :: String
  }

-- | Get the architecture, name, and version of the
-- | operating system.
foreign import os :: Effect OS

-- | fold over the keys and values of the system environment variables.
-- | First parameter is key, second is value
foreign import foldEnv :: forall a. (a -> String -> String -> a) -> a -> Effect a

getEnv :: String -> Effect (Maybe String)
getEnv key = getEnv_ key Just Nothing
foreign import getEnv_ :: String -> (String -> Maybe String) -> (Maybe String) -> Effect (Maybe String)

-- | The PID (Process ID) for the currently executing PhantomJS process.
foreign import pid :: Effect Int
