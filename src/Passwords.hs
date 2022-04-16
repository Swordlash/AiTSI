module Passwords 
  ( Password
  , PasswordHash (..)
  , generatePasswordHash
  , mkPassword
  , Passwords.validatePassword
  ) where

import Prologue

import Crypto.KDF.BCrypt
import Crypto.Random (MonadRandom)
import Servant (FromHttpApiData)

newtype Password = Password { unPassword :: Text }
  deriving newtype (PersistField, Show, PersistFieldSql, FromHttpApiData)

mkPassword :: Text -> Password
mkPassword = Password

newtype PasswordHash = PasswordHash { unPasswordHash :: ByteString }
  deriving newtype (PersistField, Show, PersistFieldSql)

internalSalt :: ByteString
internalSalt = "\241\207\NAKJTI\177\134\187QN\147*\143\245N"

generatePasswordHash :: Password -> PasswordHash
generatePasswordHash = PasswordHash . bcrypt 14 internalSalt . toS @_ @ByteString . unPassword

validatePassword :: Password -> PasswordHash -> Either [Char] Bool
validatePassword (Password password) (PasswordHash hash) = validatePasswordEither (toS @_ @ByteString password) hash