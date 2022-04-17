module Server where

import Prologue
import Servant hiding (BadPassword, NoSuchUser)
import Servant.API
import Servant.Server hiding (BadPassword, NoSuchUser)
import Servant.HTML.Blaze (HTML)
import DbConn (DbPool)
import AppMonad

import Pages.Index    qualified as Index
import Pages.Login    qualified as Login
import Pages.Register qualified as Register
import Pages.Redirect qualified as Redirect

import Text.Blaze.Html (Html)
import Network.Wai
import Network.Wai.Middleware.RequestLogger
import Logging (requestLoggingMiddleware)
import Meal (Meal', getAllMeals)

import User
import Servant.Auth.Server
import Login
import Crypto.JOSE

type API auths = (Servant.Auth.Server.Auth auths Username :> Protected) :<|> Unprotected

type Unprotected 
  = Index
  :<|> LoginAPI
  :<|> Login
  :<|> RegisterAPI
  :<|> Register

type Protected = GetAllMeals


type Index       = Get '[HTML] Html
type Login       = "login" :> Get '[HTML] Html
type Register    = "register" :> Get '[HTML] Html

type GetAllMeals = "allMeals" :> Get '[JSON] [Meal']


type API' = API '[Cookie, JWT]

appServer :: DbPool -> JWK -> Application
appServer pool key = middleware 
  $ serveWithContext apiProxy context
  $ hoistServerWithContext apiProxy confProxy (hoistServerM pool) server
  where
    apiProxy  = Proxy @API'
    confProxy = Proxy @'[CookieSettings, JWTSettings]

    context = cookieSettings :. jwtSettings :. EmptyContext

    jwtSettings = defaultJWTSettings key
    cookieSettings = defaultCookieSettings 
      { cookieIsSecure = NotSecure, cookieSameSite = SameSiteStrict, cookieXsrfSetting = Nothing }

    middleware :: Middleware
    middleware = requestLoggingMiddleware

    server :: ServerT API' AppM
    server = serveProtected :<|> serveUnprotected

    serveUnprotected :: ServerT Unprotected AppM
    serveUnprotected 
      = serveIndex 
      :<|> serveLoginAPI cookieSettings jwtSettings
      :<|> serveLogin
      :<|> serveRegisterAPI cookieSettings jwtSettings
      :<|> serveRegister

    serveIndex :: ServerT Index AppM
    serveIndex = pure Index.index

    serveLogin :: ServerT Login AppM
    serveLogin = pure Login.login

    serveRegister :: ServerT Register AppM
    serveRegister = pure Register.register

    serveProtected :: ServerT (Servant.Auth.Server.Auth auths Username :> Protected) AppM
    serveProtected = serveMeals

    withAuth :: (Username -> AppM a) -> (AuthResult Username -> AppM a)
    withAuth act = \case 
      BadPassword -> throwError err401 { errBody = "Bad password" }
      NoSuchUser  -> throwError err401 { errBody = "User not found" }
      Indefinite  -> throwError err401 { errBody = "Try other authentication method" }
      Authenticated username -> act username

    serveMeals :: AuthResult Username -> AppM [Meal']
    serveMeals = withAuth $ const $ AppM getAllMeals