module Login where

import Prologue
import Passwords (Password)
import Servant
import Web.FormUrlEncoded
import Servant (FormUrlEncoded)
import Servant.Auth.Server
import AppMonad (AppM)
import User
import Text.Blaze.Html
import Servant.HTML.Blaze (HTML)

import Pages.Redirect qualified as Redirect

type TwoCookies a = (Headers '[ Header "Set-Cookie" SetCookie
                              , Header "Set-Cookie" SetCookie
                              ]
                              a)

type NoContentTwoCookies = TwoCookies NoContent

acceptLoginUsername :: (MonadIO m, MonadError ServerError m) => CookieSettings -> JWTSettings -> Username -> a -> m (TwoCookies a)
acceptLoginUsername cs jwt username v = do
  withTwoCookies'm <- liftIO $ acceptLogin cs jwt username
  case withTwoCookies'm of
    Nothing           -> throwError err401 { errBody = "Cannot apply cookies" }
    Just applyCookies -> return $ applyCookies v

--------------------------------------------------------------------------

data LoginForm = LoginForm { username :: Text, password :: Password }
  deriving stock Generic
  deriving anyclass FromForm

type LoginAPI
  =  "api"
  :> "login"
  :> ReqBody '[FormUrlEncoded] LoginForm
  :> Post '[HTML] (TwoCookies Html)

serveLoginAPI :: CookieSettings -> JWTSettings -> ServerT LoginAPI AppM
serveLoginAPI cs jwts LoginForm{username, password} = do
  backend <- ask
  username'e <- runExceptT $ flip runReaderT backend $ checkCreds username password
  case username'e of
    Left err       -> throwError err401 { errBody = toS err }
    Right username -> acceptLoginUsername cs jwts username (Redirect.redirect "/hello")

--------------------------------------------------------------------------

data RegisterForm = RegisterForm { firstName :: Text, lastName :: Text, username :: Username, password :: Password }
  deriving stock Generic
  deriving anyclass FromForm

type RegisterAPI
  = "api"
  :> "register"
  :> ReqBody '[FormUrlEncoded] RegisterForm
  :> Post '[HTML] (TwoCookies Html)

serveRegisterAPI :: CookieSettings -> JWTSettings -> ServerT RegisterAPI AppM
serveRegisterAPI cs jwts RegisterForm{..} = do
  backend <- ask
  addUser username firstName lastName password `runReaderT` backend
  acceptLoginUsername cs jwts username (Redirect.redirect "/hello")