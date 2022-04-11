module DbConn
  ( withServerDatabasePool
  , liftWithPool
  , DbPool(..)
  ) where

import Prologue
import Control.Monad.Logger
import Data.Pool
import Control.Monad.Reader (mapReaderT)
import GHC.IO (unsafePerformIO)

connStr :: ConnectionString
connStr = "host=localhost dbname=aitsi user=postgres password=qwerty port=5432"

newtype DbPool = DbPool { toPool :: Pool SqlBackend }

withServerDatabasePool :: (MonadLoggerIO m, MonadUnliftIO m) => (DbPool -> m a) -> m a
withServerDatabasePool act = withPostgresqlPool connStr 10 $ act . DbPool

liftWithPool :: MonadUnliftIO m => DbPool -> ReaderT SqlBackend m a -> m a
liftWithPool pool act = runSqlPool act (toPool pool)
