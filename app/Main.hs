{-# LANGUAGE TemplateHaskell #-}
module Main where

import Lib

main :: IO ()
main = print $ $static + 30
