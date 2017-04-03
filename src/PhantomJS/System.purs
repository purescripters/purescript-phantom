module PhantomJS.System
  ( os
  , OS
  , foldEnv
  , pid
  , getEnv
  ) where

import Prelude
import Data.Maybe (Maybe(..))

type OS =
  { architecture :: String
  , name :: String
  , version :: String }

-- | Get the architecture, name, and version of the
-- | operating system.
foreign import os :: OS

-- | fold over the keys and values of the system environment variables.
-- | First parameter is key, second is value
foreign import foldEnv :: forall a. (a -> String -> String -> a) -> a -> a

foreign import getEnv_ :: String -> (String -> Maybe String) -> (Maybe String) -> Maybe String

getEnv :: String -> Maybe String
getEnv key = getEnv_ key Just Nothing

-- | The PID (Process ID) for the currently executing PhantomJS process.
foreign import pid :: Int
