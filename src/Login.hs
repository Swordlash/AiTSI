module Login where

import Prologue
import Passwords (Password)
import Servant
import Web.FormUrlEncoded
import Servant (FormUrlEncoded)
import Servant.Auth.Server
import AppMonad (AppM)
import User (checkCreds)

data LoginForm = LoginForm { username :: Text, password :: Password }
  deriving stock (Generic)
  deriving anyclass (FromForm)


type Login 
  = "login"
  :> ReqBody '[FormUrlEncoded] LoginForm
  :> Verb 'POST 204 '[PlainText] (Headers '[ Header "Set-Cookie" SetCookie
                                           , Header "Set-Cookie" SetCookie
                                           ]
                                           NoContent)

serveLogin :: CookieSettings -> JWTSettings -> ServerT Login AppM
serveLogin cs jwts LoginForm{username, password} = do
  backend <- ask
  user'e <- runExceptT $ flip runReaderT backend $ checkCreds username password
  case user'e of
    Left err -> throwError err401 { errBody = toS err }
    Right user -> do
      withTwoCookies'm <- liftIO $ acceptLogin cs jwts user
      case withTwoCookies'm of
        Nothing           -> throwError err401 { errBody = "Cannot apply cookies" }
        Just applyCookies -> return $ applyCookies NoContent
