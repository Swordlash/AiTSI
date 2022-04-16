module Login where

import Prologue
import Passwords (Password)
import Servant
import Web.FormUrlEncoded
import Servant (FormUrlEncoded)
import Servant.Auth.Server
import AppMonad (AppM)
import User

type NoContentTwoCookies = (Headers '[ Header "Set-Cookie" SetCookie
                                     , Header "Set-Cookie" SetCookie
                                     ]
                                     NoContent)

acceptLoginUsername :: (MonadIO m, MonadError ServerError m) => CookieSettings -> JWTSettings -> Username -> m NoContentTwoCookies
acceptLoginUsername cs jwt username = do
  withTwoCookies'm <- liftIO $ acceptLogin cs jwt username
  case withTwoCookies'm of
    Nothing           -> throwError err401 { errBody = "Cannot apply cookies" }
    Just applyCookies -> return $ applyCookies NoContent

--------------------------------------------------------------------------

data LoginForm = LoginForm { username :: Text, password :: Password }
  deriving stock Generic
  deriving anyclass FromForm

type Login 
  = "login"
  :> ReqBody '[FormUrlEncoded] LoginForm
  :> Verb 'POST 204 '[PlainText] NoContentTwoCookies

serveLogin :: CookieSettings -> JWTSettings -> ServerT Login AppM
serveLogin cs jwts LoginForm{username, password} = do
  backend <- ask
  username'e <- runExceptT $ flip runReaderT backend $ checkCreds username password
  case username'e of
    Left err       -> throwError err401 { errBody = toS err }
    Right username -> acceptLoginUsername cs jwts username

--------------------------------------------------------------------------

data RegisterForm = RegisterForm { firstName :: Text, lastName :: Text, username :: Username, password :: Password }
  deriving stock Generic
  deriving anyclass FromForm

type Register 
  = "login"
  :> ReqBody '[FormUrlEncoded] RegisterForm
  :> Verb 'POST 204 '[PlainText] NoContentTwoCookies

serveRegister :: CookieSettings -> JWTSettings -> ServerT Register AppM
serveRegister cs jwts RegisterForm{..} = do
  backend <- ask
  addUser username firstName lastName password `runReaderT` backend
  acceptLoginUsername cs jwts username