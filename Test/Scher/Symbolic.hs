{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}

module Test.Scher.Symbolic where

import Data.Char

data Strategy = Eager | Lazy

newtype Sym t = Sym { runSym :: Strategy -> IO t }

instance Functor Sym where
  f `fmap` (Sym a) = Sym ((fmap f) . a)

instance Monad Sym where
  return a = Sym $ \strat -> return a

class Symbolic t where
  make :: String -> Sym t
