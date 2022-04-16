module Prologue 
  ( module Protolude
  , module Protolude.Conv
  , getDb
  , module Database.Persist
  , module Database.Persist.Postgresql
  , module Control.Monad.Except
  , module Control.Monad.Reader
  , ResourceT(..)
  , MonadThrow(..)
  , MonadCatch(..)
  , MonadMask(..)
  , MonadUnliftIO(..)
  , try
  ) where

import Protolude hiding (replace, toS, Handler, try, catch, mask, uninterruptibleMask)
import Protolude.Conv
import Database.Persist.Postgresql hiding (get)
import Database.Persist hiding (get)
import qualified Database.Persist
import Conduit
import Control.Monad.Catch
import Control.Monad.Reader
import Control.Monad.Except


getDb :: (PersistStoreRead backend, MonadIO m, PersistRecordBackend record backend) 
  => Key record -> ReaderT backend m (Maybe record)
getDb = Database.Persist.get