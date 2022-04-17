module Pages.Redirect where

import Prologue
import Text.Blaze.Html (Html, (!))
import Text.Blaze.Html5 qualified as H
import Text.Blaze.Html5.Attributes qualified as HA

redirect :: H.AttributeValue -> Html
redirect url = H.docTypeHtml 
  $ H.html 
  $ H.head
  $ H.meta ! HA.httpEquiv "refresh" ! HA.content ("0; url=" <> url)