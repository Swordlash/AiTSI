module Meal where

import Prologue


data Macro = Macro
  { calories :: Double
  , carbohydrates :: Double
  , fat :: Double
  , protein :: Double
  }

--getMealMacro :: (MonadIO m, MonadReader SqlBackend m) => Text -> m Macro