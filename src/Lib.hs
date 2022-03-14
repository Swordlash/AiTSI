{-# LANGUAGE TemplateHaskell #-}
module Lib where

import Language.Haskell.TH

x :: Int
x = 42

static :: Q Exp
static = [| x |]