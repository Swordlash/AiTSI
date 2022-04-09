module DbConn (withServerDatabase) where

import Prologue
import Control.Monad.Logger

connStr = "host=localhost dbname=aitsi user=postgres password=qwerty port=5432"

logPath = "server.log"

withServerDatabase :: ReaderT SqlBackend (NoLoggingT (ResourceT IO)) a -> IO a
withServerDatabase act 
  = runFileLoggingT logPath $ withPostgresqlPool connStr 10 (liftIO . runSqlPersistMPool act)
