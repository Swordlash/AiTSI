module Tables where

import Prologue
import Database.Persist.TH
import Passwords (PasswordHash(..))

import Data.Aeson

share [ mkPersist sqlSettings, mkMigrate "migrateAllTables" ] [persistLowerCase|
Ingredient
  name Text
  quantity Double
  calories Double
  carbohydrates Double
  fat Double
  protein Double
  UniqueIngredientName name
  deriving Generic Show Eq

Meal
  name Text
  UniqueMealName name
  deriving Generic Show

IsIngredient
  ingredientId IngredientId DeleteCascade
  mealId MealId DeleteCascade
  ingredientQuantity Double
  UniqueIsIngredient ingredientId mealId
  deriving Generic Show
|]

instance Ord Ingredient where
  compare = comparing ingredientName

instance ToJSONKey Ingredient
instance ToJSON Ingredient
instance FromJSON Ingredient

instance ToJSON Meal
instance FromJSON Meal