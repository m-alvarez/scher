module Test.Scher.Equiv (Equiv(equiv)) where

import Jhc.Prim.Rts

foreign import ccall "c_ptr_eql" c_ptr_eql :: Bang_ a -> Bang_ a -> Bool

ptr_eql :: a -> a -> Bool
ptr_eql x y = c_ptr_eql (toBang_ x) (toBang_ y)

-- A class for shallow, pointer-based equality
-- It's as dangerous as it sounds!
-- Unfortunately, we need to reduce to WHNF
class (Eq t) => Equiv t where
  equiv :: t -> t -> Bool

instance Equiv Int where
  equiv x y = x `ptr_eql` y || x == y

instance Equiv Integer where
  equiv x y = x `ptr_eql` y || x == y

instance Equiv Bool where
  equiv x y = x `ptr_eql` y || x == y

instance Equiv Char where
  equiv x y = x `ptr_eql` y || x == y

instance (Equiv t) => Equiv [t] where
  equiv l1 l2 = l1 `ptr_eql` l2 ||
    case (l1, l2) of
      ([], [])     -> True
      ([], _:_)    -> False
      (_:_, [])    -> False
      (a:a', b:b') -> a `equiv` b && a' `equiv` b'

instance (Equiv t1, Equiv t2) => Equiv (t1, t2) where
  equiv x y = x `ptr_eql` y ||
    let (x1, x2) = x
        (y1, y2) = y
    in x1 `equiv` y1 && x2 `equiv` y2

instance (Equiv t1, Equiv t2, Equiv t3) => Equiv (t1, t2, t3) where
  equiv x y = x `ptr_eql` y ||
    let (x1, x2, x3) = x
        (y1, y2, y3) = y
    in x1 `equiv` y1 && x2 `equiv` y2 && x3 `equiv` y3

instance (Equiv t1, Equiv t2, Equiv t3, Equiv t4) => Equiv (t1, t2, t3, t4) where
  equiv x y = x `ptr_eql` y ||
    let (x1, x2, x3, x4) = x
        (y1, y2, y3, y4) = y
    in x1 `equiv` y1 && x2 `equiv` y2 && x3 `equiv` y3 && x4 `equiv` y4

instance (Equiv t1, Equiv t2) => Equiv (Either t1 t2) where
  equiv x y = x `ptr_eql` y ||
    case (x, y) of
      (Left a, Left b)   -> a `equiv` b
      (Right a, Right b) -> a `equiv` b
      _                  -> False

instance (Equiv t) => Equiv (Maybe t) where
  equiv x y = x `ptr_eql` y ||
    case (x, y) of
      (Nothing, Nothing) -> True
      (Just a, Just b)   -> a `equiv` b
      _                  -> False
