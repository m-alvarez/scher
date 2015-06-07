module Test.Scher.Klee
  ( module Common )
  where

import qualified Test.Scher.Klee.Pure as Lazy
import qualified Test.Scher.Klee.Impure as Strict
import qualified Test.Scher.Klee.Common as Common
import Test.Scher.Symbolic
import Data.Char

instance Symbolic Int where
  make name = Sym $ \strat ->
    case strat of
      Eager -> Strict.int name
      Lazy -> Lazy.int name

instance Symbolic Char where
  make name = do
    i <- make (name ++ "%CharVal")
    return (chr $ i `mod` 256)

instance Symbolic Bool where
  make name = do
    i <- make (name ++ "%BoolVal") :: Sym Int
    return $ i `mod` 2 == 0

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
