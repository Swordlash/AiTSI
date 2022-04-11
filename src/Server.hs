module Server where

import Prologue
import Servant
import Servant.API
import Servant.Server
import Servant.HTML.Blaze (HTML)
import DbConn (DbPool)
import AppMonad (serveApp, AppM)

import Pages.Index qualified as Index
import Text.Blaze.Html (Html)
import Network.Wai
import Network.Wai.Middleware.RequestLogger
import Logging (requestLoggingMiddleware)


type API =
  Index

type Index = Get '[HTML] Html


appServer :: DbPool -> Application
appServer pool = middleware $ serveApp pool (Proxy @API) server
  where
    middleware :: Middleware
    middleware = requestLoggingMiddleware

    server :: ServerT API AppM
    server = serveIndex

    serveIndex :: ServerT Index AppM
    serveIndex = pure Index.index