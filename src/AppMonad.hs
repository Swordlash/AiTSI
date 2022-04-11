module AppMonad where

import Prologue
import Control.Monad.Logger
import Servant

import DbConn
import Data.Pool (Pool)
import Logging (runLogging)

newtype AppM a = AppM { runServerM :: ReaderT SqlBackend (LoggingT IO) a }
  deriving newtype 
    ( Functor
    , Applicative
    , Monad
    , MonadIO
    , MonadUnliftIO
    , MonadThrow
    , MonadCatch
    , MonadMask
    , MonadReader SqlBackend
    , MonadLogger
    , MonadLoggerIO
    )

instance MonadError ServerError AppM where
  throwError = throwM
  catchError = catch

hoistServerM :: forall a. DbPool -> AppM a -> Handler a
hoistServerM pool =
  Handler
  . ExceptT
  . try
  . runLogging
  . liftWithPool pool
  . runServerM

serveApp :: HasServer api '[] => DbPool -> Proxy api -> ServerT api AppM -> Application
serveApp pool proxy = serve proxy . hoistServer proxy (hoistServerM pool)