module Request where

import Data.JSDate (JSDate)

data HTTPMethod
  = GET
  | POST

newtype RequestData = RequestData
  { id :: Int
  , method :: HTTPMethod
  , url :: String
  , time :: JSDate
  , headers :: Array { key :: String, value :: String} 
  }
