module Clay.Instances where

import Prologue
import Network.HTTP.Media qualified as M
import Servant.API                     (Accept (..), MimeRender (..))
import Data.List.NonEmpty qualified as NE
import Clay

data CSS

instance Accept CSS where
  contentType _ = "text" M.// "css"

instance MimeRender CSS Css where 
  mimeRender _ = toS . renderWith compact []