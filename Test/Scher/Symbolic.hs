module Test.Scher.Symbolic where

import Data.Char
import Data.Functor

data Strategy = Eager | Lazy

newtype Sym t = Sym { runSym :: Strategy -> IO t }

instance Functor Sym where
  f `fmap` (Sym a) = Sym ((fmap f) . a)

instance Monad Sym where
  return a  = Sym $ \strat -> return a
  (>>=) a f = Sym $ \strat -> do
    a' <- runSym a strat
    runSym (f a') strat

class Symbolic t where
  make :: String -> Sym t
