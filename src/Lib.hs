module Lib where

import Tables
import Database.Persist.Postgresql
import Control.Monad.Logger
import Control.Monad.IO.Class
import Test (prepareTestDatabase)

connStr = "host=localhost dbname=aitsi user=postgres password=qwerty port=5432"

main :: IO ()
main = runStderrLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
    flip runSqlPersistMPool pool $ do
        prepareTestDatabase