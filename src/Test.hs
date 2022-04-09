module Test where

import Prologue

import Tables

prepareTestDatabase :: MonadIO m => ReaderT SqlBackend m ()
prepareTestDatabase = do
  runMigrationUnsafe migrateAll

  deleteWhere ([] :: [Filter Ingredient])
  deleteWhere ([] :: [Filter User])
  deleteWhere ([] :: [Filter IsIngredient])

  insert $ Ingredient 
    { ingredientName = "Pierś kurczaka"
    , ingredientFat = 3.6
    , ingredientCarbohydrates = 0
    , ingredientProtein = 31
    , ingredientCalories = 31*4 + 3.6*9
    , ingredientQuantity = 100
    }
  
  pure ()