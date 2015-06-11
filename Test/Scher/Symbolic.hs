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
-- This syntax dodges a bug in the desugaring
instance (Symbolic t) => Symbolic [t] where
  make name =
    make (name ++ "%IsCons")
    >>= \end ->
    if end
    then return []
    else make (name ++ "%car")
         >>= \hd ->
         make (name ++ "%cdr")
         >>= \tl ->
         return $ hd : tl

instance (Symbolic t1, Symbolic t2) => Symbolic (t1, t2) where
  make name = do
    x1 <- make (name ++ "%1")
    x2 <- make (name ++ "%2")
    return (x1, x2)

instance (Symbolic t1, Symbolic t2, Symbolic t3) => Symbolic (t1, t2, t3) where
  make name = do
    x1 <- make (name ++ "%1")
    x2 <- make (name ++ "%2")
    x3 <- make (name ++ "%3")
    return (x1, x2, x3)

instance (Symbolic t1, Symbolic t2, Symbolic t3, Symbolic t4) => Symbolic (t1, t2, t3, t4) where
  make name = do
    x1 <- make (name ++ "%1")
    x2 <- make (name ++ "%2")
    x3 <- make (name ++ "%3")
    x4 <- make (name ++ "%4")
    return (x1, x2, x3, x4)

instance (Symbolic t1, Symbolic t2) => Symbolic (Either t1 t2) where
  make name =
    make (name ++ "#isLeft") 
    >>= \choice ->
    if choice
    then Left `fmap` make name
    else Right `fmap` make name

instance (Symbolic t) => Symbolic (Maybe t) where
  make name =
    make (name ++ "%IsJust")
    >>= \isJust ->
    if isJust
    then Just `fmap` make name
    else return Nothing
