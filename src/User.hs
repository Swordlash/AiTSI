module User where

import Prologue
import Database.Persist.TH
import Passwords
import Data.Either.Extra (mapLeft)
import Data.Aeson
import Servant.Auth.JWT

newtype Username = Username Text
  deriving newtype (Show, ToJSON, FromJSON, PersistField, PersistFieldSql)
  deriving anyclass (ToJWT, FromJWT)

share [ mkPersist sqlSettings, mkMigrate "migrateAllUsers" ] [persistLowerCase|
User
  firstName Text
  lastName Text
  userName Username
  bcryptHash PasswordHash
  UniqueUsername userName
  UniqueUser firstName lastName
  deriving Generic Show
|]

checkCreds :: MonadIO m => Text -> Password -> ReaderT SqlBackend (ExceptT Text m) Username
checkCreds username password = do
  user <- fmap entityVal . mapReaderT (ExceptT . fmap (note "User not found")) 
    $ selectFirst [ UserUserName ==. Username username ] []
  
  valid <- liftEither . mapLeft toS $ validatePassword password (userBcryptHash user)

  if valid
    then pure $ userUserName user
    else throwError "Invalid password"