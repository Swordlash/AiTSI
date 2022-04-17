module Pages.Index (index) where

import Prologue
import Text.Blaze.Html (Html)
import Text.Blaze.Html5 qualified as H
import User (Username(..))

index :: Username -> Html
index (Username username) = H.docTypeHtml $ H.html $ do
  H.head $ H.title "Hello Blaze!"
  H.body $ do
    H.p $ H.text $ "Welcome " <> username