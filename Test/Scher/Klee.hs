module Test.Scher.Klee
  ( assert
  , range
  )
  where

import qualified Test.Scher.Klee.Pure as Lazy
import qualified Test.Scher.Klee.Impure as Strict
import qualified Test.Scher.Klee.Common as Common
import Test.Scher.Symbolic
import Data.Char

assert :: Bool -> Sym ()
assert b = Sym $ \strat -> Common.assert b

range :: Int -> Int -> String -> Sym Int
range lo hi name = Sym $ \strat ->
  case strat of
    Eager -> Strict.range lo hi name
    Lazy  -> return $ Lazy.range lo hi name

instance Symbolic Int where
  make name = Sym $ \strat ->
    case strat of
      Eager -> Strict.int name
      Lazy  -> return $ Lazy.int name

instance Symbolic Char where
  make name = do
    i <- make (name ++ "%CharVal")
    return (chr $ i `rem` 256)

instance Symbolic Bool where
  make name = do
    i <- make (name ++ "%BoolVal") :: Sym Int
    return $ i `rem` 2 == 0
