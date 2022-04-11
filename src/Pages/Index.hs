module Pages.Index (index) where

import Prologue
import Text.Blaze.Html (Html)
import Text.Blaze.Html5 qualified as H

index :: Html
index = H.docTypeHtml $ do
  H.head $ H.title "Hello Blaze!"
  H.body $ do
    H.p $ H.text "Welcome user"