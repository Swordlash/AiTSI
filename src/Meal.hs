module Meal where

import Prologue hiding (from, on, (==.))
import Tables

import Data.List.Extra qualified as L

import Database.Esqueleto.Experimental as E

import Data.Map.Strict qualified as M
import Data.Aeson

data Macro = Macro
  { calories :: Double
  , carbohydrates :: Double
  , fat :: Double
  , protein :: Double
  }

data Meal' = Meal'
  { name :: Text
  , ingredients :: Map Ingredient Double
  } deriving stock (Generic)
    deriving anyclass (ToJSON)

getAllMeals :: MonadIO m => ReaderT SqlBackend m [Meal']
getAllMeals = do
  list <- E.select $ do
    (meal :& isIngr :& ingr) <- from $ 
      table @Meal
      `innerJoin`
      table @IsIngredient
      `on`
      (\(meal :& isIngr) -> meal ^. MealId ==. isIngr ^. IsIngredientMealId)
      `innerJoin` table @Ingredient
      `on` 
      (\(_ :& isIngr :& ingr) -> isIngr ^. IsIngredientIngredientId ==. ingr ^. IngredientId)
    
    pure (meal, isIngr, ingr)
  
  pure 
    $ map (\(mealName, ingrList) -> Meal' mealName (M.fromList ingrList))
    $ L.groupSort
    $ map (\(ment, isIngrEnt, ingrEnt) -> ( mealName $ entityVal ment
                                          , ( entityVal ingrEnt
                                            , isIngredientIngredientQuantity $ entityVal isIngrEnt
                                            )
                                          ))
    list
    


--getMealMacro :: (MonadIO m, MonadReader SqlBackend m) => Text -> m Macro