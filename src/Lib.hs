module Lib where

import Prologue

import Control.Monad.Logger
import Test (prepareTestDatabase)
import DbConn (withServerDatabase)


main :: IO ()
main = withServerDatabase prepareTestDatabase