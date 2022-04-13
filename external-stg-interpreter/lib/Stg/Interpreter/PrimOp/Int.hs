{-# LANGUAGE RecordWildCards, LambdaCase, OverloadedStrings, PatternSynonyms, Strict #-}
{-# LANGUAGE MagicHash, UnboxedTuples, BangPatterns #-}
module Stg.Interpreter.PrimOp.Int where

import GHC.Exts
import Foreign.Storable (sizeOf)
import Data.Int
import Data.Word
import Data.Bits
import Data.Char

import Stg.Syntax
import Stg.Interpreter.Base

type PrimInt  = Int64
type PrimWord = Word64

pattern CharV c   = Literal (LitChar c)
pattern IntV i    = IntAtom i -- Literal (LitNumber LitNumInt i)
pattern WordV i   = WordAtom i -- Literal (LitNumber LitNumWord i)
pattern FloatV f  = FloatAtom f
pattern DoubleV d = DoubleAtom d

primOps :: [(Name, PrimOpFunDef)]
primOps = getPrimOpList $ do

      -- +# :: Int# -> Int# -> Int#
  defOp "+#" $ \[IntV a, IntV b] -> pure [IntV $ a + b]

      -- -# :: Int# -> Int# -> Int#
  defOp "-#" $ \[IntV a, IntV b] -> pure [IntV $ a - b]

      -- *# :: Int# -> Int# -> Int#
  defOp "*#" $ \[IntV a, IntV b] -> pure [IntV $ a * b]

      -- timesInt2# :: Int# -> Int# -> (# Int#, Int#, Int# #)
  defOp "timesInt2#" $ \[IntV a, IntV b] ->
   let
    (isHighNeeded, hi, lo) = genericIMul2 a b

    -- HINT: this code is from suite/tests/codeGen/should_run/cgrun079.hs
    --       genericIMul2 is a generic implementation of the timesInt2# primop
    genericIMul2 :: Int -> Int -> (Int,Int,Int)
    genericIMul2 x y = (c,h,l)
       where
          (p,l) = timesWord2 (fromIntegral x) (fromIntegral y)
          h = p - f x y - f y x
          c = if h == carryFill l then 0 else 1
          f u v = carryFill u .&. v

          -- Return either 00..00 or FF..FF depending on the carry
          carryFill :: Int -> Int
          carryFill x = x `shiftR` (wordSizeInBits - 1)

    wordSizeInBits :: Int
    wordSizeInBits = 8 * sizeOf (0 :: Word)

    timesWord2 :: Word -> Word -> (Int,Int)
    timesWord2 (W# x) (W# y) = case timesWord2# x y of
       (# h, l #) -> (I# (word2Int# h), I# (word2Int# l))
   in pure [IntV isHighNeeded, IntV hi, IntV lo]

      -- mulIntMayOflo# :: Int# -> Int# -> Int#
  defOp "mulIntMayOflo#"  $ \[IntV a, IntV b] -> pure [IntV $ if fromIntegral a * (fromIntegral b :: Integer) > fromIntegral (maxBound :: PrimInt) then 1 else 0]

      -- quotInt# :: Int# -> Int# -> Int#
  defOp "quotInt#"        $ \[IntV a, IntV b] -> pure [IntV $ a `quot` b]  -- NOTE: int / int in C

      -- remInt# :: Int# -> Int# -> Int#
  defOp "remInt#"         $ \[IntV a, IntV b] -> pure [IntV $ a `rem` b]   -- NOTE: int % int in C

      -- quotRemInt# :: Int# -> Int# -> (# Int#, Int# #)
  defOp "quotRemInt#"     $ \[IntV a, IntV b] -> pure [IntV $ a `quot` b, IntV $ a `rem` b]

      -- andI# :: Int# -> Int# -> Int#
  defOp "andI#"           $ \[IntV a, IntV b] -> pure [IntV $ a .&. b]

      -- orI# :: Int# -> Int# -> Int#
  defOp "orI#"            $ \[IntV a, IntV b] -> pure [IntV $ a .|. b]

      -- xorI# :: Int# -> Int# -> Int#
  defOp "xorI#"           $ \[IntV a, IntV b] -> pure [IntV $ a `xor` b]

      -- notI# :: Int# -> Int#
  defOp "notI#"           $ \[IntV a] -> pure [IntV $ complement a]

      -- negateInt# :: Int# -> Int#
  defOp "negateInt#"      $ \[IntV a] -> pure [IntV (-a)]

      -- addIntC# :: Int# -> Int# -> (# Int#, Int# #)
  defOp "addIntC#"        $ \[IntV a, IntV b] ->
                                    let
                                      carry :: Integer -> Int
                                      carry x = if x < fromIntegral (minBound :: PrimInt) || x > fromIntegral (maxBound :: PrimInt) then 1 else 0
                                    in pure
                                        [ IntV $ a + b
                                        , IntV . carry $ fromIntegral a + fromIntegral b
                                        ]

      -- subIntC# :: Int# -> Int# -> (# Int#, Int# #)
  defOp "subIntC#"        $ \[IntV a, IntV b] ->
                                    let
                                      carry :: Integer -> Int
                                      carry x = if x < fromIntegral (minBound :: PrimInt) || x > fromIntegral (maxBound :: PrimInt) then 1 else 0
                                    in pure
                                        [ IntV $ a - b
                                        , IntV . carry $ fromIntegral a - fromIntegral b
                                        ]

      -- ># :: Int# -> Int# -> Int#
  defOp ">#"  $ \[IntV a, IntV b] -> pure [IntV $ if a > b  then 1 else 0]

      -- >=# :: Int# -> Int# -> Int#
  defOp ">=#" $ \[IntV a, IntV b] -> pure [IntV $ if a >= b then 1 else 0]

      -- ==# :: Int# -> Int# -> Int#
  defOp "==#" $ \[IntV a, IntV b] -> pure [IntV $ if a == b then 1 else 0]

      -- /=# :: Int# -> Int# -> Int#
  defOp "/=#" $ \[IntV a, IntV b] -> pure [IntV $ if a /= b then 1 else 0]

      -- <# :: Int# -> Int# -> Int#
  defOp "<#"  $ \[IntV a, IntV b] -> pure [IntV $ if a < b  then 1 else 0]

      -- <=# :: Int# -> Int# -> Int#
  defOp "<=#" $ \[IntV a, IntV b] -> pure [IntV $ if a <= b then 1 else 0]

      -- chr# :: Int# -> Char#
  defOp "chr#"                $ \[IntV a] -> pure [CharV . chr $ fromIntegral a] -- HINT: noop ; same bit level representation

      -- int2Word# :: Int# -> Word#
  defOp "int2Word#"           $ \[IntV a] -> pure [WordV $ fromIntegral a] -- HINT: noop ; same bit level representation

      -- int2Float# :: Int# -> Float#
  defOp "int2Float#"          $ \[IntV a] -> pure [FloatV $ fromIntegral a]

      -- int2Double# :: Int# -> Double#
  defOp "int2Double#"         $ \[IntV a] -> pure [DoubleV $ fromIntegral a]

      -- word2Float# :: Word# -> Float#
  defOp "word2Float#"         $ \[WordV a] -> pure [FloatV $ fromIntegral a]

      -- word2Double# :: Word# -> Double#
  defOp "word2Double#"        $ \[WordV a] -> pure [DoubleV $ fromIntegral a]

      -- uncheckedIShiftL# :: Int# -> Int# -> Int#
  defOp "uncheckedIShiftL#"   $ \[IntV a, IntV b] -> pure [IntV $ unsafeShiftL a (fromIntegral b)]

      -- uncheckedIShiftRA# :: Int# -> Int# -> Int#
  defOp "uncheckedIShiftRA#"  $ \[IntV a, IntV b] -> pure [IntV $ unsafeShiftR a (fromIntegral b)] -- Shift right arithmetic

      -- uncheckedIShiftRL# :: Int# -> Int# -> Int#
  defOp "uncheckedIShiftRL#"  $ \[IntV a, IntV b] -> pure [IntV $ fromIntegral $ unsafeShiftR (fromIntegral a :: PrimWord) (fromIntegral b)] -- Shift right logical
