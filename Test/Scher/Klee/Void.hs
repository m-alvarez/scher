module Test.Scher.Klee.Void
  ( int
  , integer
  , range
  , M
  , run
  )
  where

type M = IO

run :: M a -> IO a
run = id

int :: String -> M Int
int name = return 0

integer :: String -> M Integer
integer name = return 0

range :: Int -> Int -> String -> M Int
range low high name = return low
