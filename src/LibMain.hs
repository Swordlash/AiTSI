module LibMain where

import Prologue

import Control.Monad.Logger
import Test (prepareTestDatabase)
import DbConn (withServerDatabasePool, liftWithPool)
import Logging (forkLoggingThread, runLogging)

import Network.Wai.Handler.Warp (run)
import Server
import Servant.Auth.Server (generateKey)

main :: IO ()
main = do
  forkLoggingThread
  key <- generateKey
  runLogging $ withServerDatabasePool $ \pool -> do
    liftWithPool pool prepareTestDatabase
    liftIO $ run 8080 (appServer pool key)