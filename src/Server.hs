module Server where

import Prologue
import Servant
import Servant.API
import Servant.Server
import Servant.HTML.Blaze (HTML)
import DbConn (DbPool)
import AppMonad

import Pages.Index qualified as Index
import Text.Blaze.Html (Html)
import Network.Wai
import Network.Wai.Middleware.RequestLogger
import Logging (requestLoggingMiddleware)
import Meal (Meal', getAllMeals)


type API =
  Index
  :<|> GetAllMeals

type Index = Get '[HTML] Html

type GetAllMeals = "allMeals" :> Get '[JSON] [Meal']


appServer :: DbPool -> Application
appServer pool = middleware $ serveApp pool (Proxy @API) server
  where
    middleware :: Middleware
    middleware = requestLoggingMiddleware

    server :: ServerT API AppM
    server = serveIndex :<|> serveMeals

    serveIndex :: ServerT Index AppM
    serveIndex = pure Index.index

    serveMeals :: ServerT GetAllMeals AppM
    serveMeals = AppM getAllMeals