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
  = LoginAPI
  :<|> Login
  :<|> RegisterAPI
  :<|> Register

type Protected = Index :<|> GetAllMeals


type Index       = "hello" :> Get '[HTML] Html
type Login       = Get '[HTML] Html
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
      { cookieIsSecure = NotSecure
      , cookieSameSite = SameSiteStrict
      , cookieXsrfSetting = Nothing 
      }

    middleware :: Middleware
    middleware = requestLoggingMiddleware

    server :: ServerT API' AppM
    server = serveProtected :<|> serveUnprotected

    serveUnprotected :: ServerT Unprotected AppM
    serveUnprotected 
      = serveLoginAPI cookieSettings jwtSettings
      :<|> serveLogin
      :<|> serveRegisterAPI cookieSettings jwtSettings
      :<|> serveRegister

    serveIndex :: Username -> AppM Html
    serveIndex = pure . Index.index

    serveLogin :: ServerT Login AppM
    serveLogin = pure Login.login

    serveRegister :: ServerT Register AppM
    serveRegister = pure Register.register

    serveProtected :: AuthResult Username -> ServerT Protected AppM
    serveProtected result = case result of
      BadPassword -> throwAll err401 { errBody = "Bad password" }
      NoSuchUser  -> throwAll err401 { errBody = "User not found" }
      Indefinite  -> throwAll err401 { errBody = "Try other authentication method" }
      Authenticated username -> serveIndex username :<|> serveMeals

    serveMeals :: ServerT GetAllMeals AppM
    serveMeals = AppM getAllMeals