module Logging 
  ( forkLoggingThread
  , runLogging
  , requestLoggingMiddleware
  ) where

import Prologue
import Control.Monad.Logger
import GHC.IO (unsafePerformIO)

import Data.Default
import Network.Wai.Middleware.RequestLogger
import Network.Wai (Middleware)

logPath :: FilePath
logPath = "server.log"

{-# NOINLINE logChan #-}
logChan :: Chan LogLine
logChan = unsafePerformIO newChan

forkLoggingThread :: IO ()
forkLoggingThread = void $ forkIO $ runFileLoggingT logPath $ unChanLoggingT logChan

{-# NOINLINE requestLoggingMiddleware #-}
requestLoggingMiddleware :: Middleware
requestLoggingMiddleware = unsafePerformIO $ mkRequestLogger def
  { destination = Callback $ writeChan logChan . (defaultLoc, "SERVER", LevelInfo,)
  }

runLogging :: MonadUnliftIO m => LoggingT m a -> m a
runLogging = runChanLoggingT logChan