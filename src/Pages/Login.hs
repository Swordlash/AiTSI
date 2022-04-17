module Pages.Login where

import Prologue
import Text.Blaze.Html (Html, (!))
import Text.Blaze.Html5 qualified as H
import Text.Blaze.Html5.Attributes qualified as HA


login :: Html
login = H.docTypeHtml $ H.html $ do
  H.head $ H.title "Login"
  H.body $ do
    H.p $ do
      H.h2 "Login"
      H.form ! HA.action "/api/login" ! HA.method "post" ! HA.autocomplete "on" $ do
        H.label ! HA.for "username" $ H.text "Username:"
        H.input ! HA.type_ "text" ! HA.name "username" ! HA.id "username"
        H.br
        H.label ! HA.for "password" $ H.text "Password:"
        H.input ! HA.type_ "password" ! HA.name "password" ! HA.id "password"
        H.br
        H.input ! HA.type_ "submit" ! HA.value "Login"
    H.p $ do
      H.h2 $ H.text "Or register:"
      H.a ! HA.href "/register" $ H.button $ H.text "Register"
