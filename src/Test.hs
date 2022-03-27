module Test where

import Tables
import Database.Persist.Postgresql (runMigration, SqlBackend, PersistQueryWrite (..), Filter, PersistStoreWrite (insert), runMigrationUnsafe)
import Control.Monad.Reader



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