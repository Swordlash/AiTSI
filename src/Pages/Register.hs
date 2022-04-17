module Pages.Register where

import Prologue
import Text.Blaze.Html (Html, (!))
import Text.Blaze.Html5 qualified as H
import Text.Blaze.Html5.Attributes qualified as HA


register :: Html
register = H.docTypeHtml $ H.html $ do
  H.head $ H.title "Register"
  H.body $ do
    H.form ! HA.action "/api/register" ! HA.method "post" ! HA.autocomplete "on" $ do
      H.label ! HA.for "username" $ H.text "Username:"
      H.input ! HA.type_ "text" ! HA.name "username" ! HA.id "username"
      H.br
      H.label ! HA.for "firstName" $ H.text "First name:"
      H.input ! HA.type_ "text" ! HA.name "firstName" ! HA.id "firstName"
      H.br
      H.label ! HA.for "lastName" $ H.text "Last name:"
      H.input ! HA.type_ "text" ! HA.name "lastName" ! HA.id "lastName"
      H.br
      H.label ! HA.for "password" $ H.text "Password:"
      H.input ! HA.type_ "password" ! HA.name "password" ! HA.id "password"
      H.br
      H.input ! HA.type_ "submit" ! HA.value "Register"
