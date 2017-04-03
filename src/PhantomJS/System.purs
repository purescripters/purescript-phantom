module PhantomJS.System
  ( os
  , OS
  , foldEnv
  , pid
  , getEnv
  ) where

import Prelude
import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe(..))
import PhantomJS.Phantom (PHANTOMJS)

type OS =
  { architecture :: String
  , name :: String
  , version :: String }

-- | Get the architecture, name, and version of the
-- | operating system.
foreign import os :: forall e. Eff (phantomjs :: PHANTOMJS | e) OS

-- | fold over the keys and values of the system environment variables.
-- | First parameter is key, second is value
foreign import foldEnv :: forall e a. (a -> String -> String -> a) -> a -> Eff (phantomjs :: PHANTOMJS | e) a

foreign import getEnv_ :: forall e. String -> (String -> Maybe String) -> (Maybe String) -> Eff (phantomjs :: PHANTOMJS | e) (Maybe String)

getEnv :: forall e. String -> Eff (phantomjs :: PHANTOMJS | e) (Maybe String)
getEnv key = getEnv_ key Just Nothing

-- | The PID (Process ID) for the currently executing PhantomJS process.
foreign import pid :: forall e. Eff (phantomjs :: PHANTOMJS | e) Int
