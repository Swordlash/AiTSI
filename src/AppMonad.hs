module AppMonad where

import Prologue
import Control.Monad.Logger
import Servant

import DbConn

newtype ServerM a = ServerM { runServerM :: ReaderT SqlBackend (NoLoggingT (ResourceT IO)) a }
  deriving newtype (Functor, Applicative, Monad, MonadThrow, MonadCatch, MonadMask)

instance MonadError ServerError ServerM where
  throwError = throwM
  catchError = catch

hoistServerM :: forall a. ServerM a -> Handler a
hoistServerM =
  Handler
  . ExceptT
  . withServerDatabase
  . try
  . runServerM

serveApp :: HasServer api '[] => Proxy api -> ServerT api ServerM -> Application
serveApp proxy = serve proxy . hoistServer proxy hoistServerM