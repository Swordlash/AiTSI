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

newtype Password = Password { toByteString :: ByteString }
  deriving newtype (PersistField, Show, PersistFieldSql)

mkPassword :: ByteString -> Password
mkPassword = Password

newtype PasswordHash = PasswordHash { toByteString :: ByteString }
  deriving newtype (PersistField, Show, PersistFieldSql)

internalSalt :: ByteString
internalSalt = "\241\207\NAKJTI\177\134\187QN\147*\143\245N"

generatePasswordHash :: Password -> PasswordHash
generatePasswordHash = PasswordHash . bcrypt 14 internalSalt . (toByteString :: Password -> ByteString)

validatePassword :: Password -> PasswordHash -> Either [Char] Bool
validatePassword (Password password) (PasswordHash hash) = validatePasswordEither password hash