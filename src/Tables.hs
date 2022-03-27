module Tables where

import Data.Text
import Data.ByteString
import Database.Persist
import Database.Persist.TH

share [ mkPersist sqlSettings, mkMigrate "migrateAll" ] [persistLowerCase|
Ingredient
  name Text
  quantity Double
  calories Double
  carbohydrates Double
  fat Double
  protein Double
  UniqueIngredientName name
  deriving Show

Meal
  name Text
  UniqueMealName name
  deriving Show

IsIngredient
  ingredientId IngredientId DeleteCascade
  mealId MealId DeleteCascade
  UniqueIsIngredient ingredientId mealId
  deriving Show

User
  firstName Text
  lastName Text
  bcryptHash ByteString
  UniqueUser firstName lastName
  deriving Show
|]