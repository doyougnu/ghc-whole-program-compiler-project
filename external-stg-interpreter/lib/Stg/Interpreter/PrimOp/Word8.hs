{-# LANGUAGE RecordWildCards, LambdaCase, OverloadedStrings, PatternSynonyms, Strict #-}
module Stg.Interpreter.PrimOp.Word8 where

import Stg.Syntax
import Stg.Interpreter.Base

import Data.Word
import Data.Bits

pattern IntV i    = IntAtom i -- Literal (LitNumber LitNumInt i)
pattern WordV i   = WordAtom i -- Literal (LitNumber LitNumWord i)
pattern Word8V i  = WordAtom i -- Literal (LitNumber LitNumWord i)

primOps :: [(Name, PrimOpFunDef)]
primOps = getPrimOpList $ do
  let
    w8  = fromIntegral :: Word -> Word8
    w   = fromIntegral :: Word8 -> Word

      -- extendWord8# :: Word8# -> Word#
  defOp "extendWord8#"  $ \[Word8V a]            -> pure [WordV a]

      -- narrowWord8# :: Word# -> Word8#
  defOp "narrowWord8#"  $ \[WordV a]             -> pure [Word8V . w . w8 $ a]

      -- notWord8# :: Word8# -> Word8#
  defOp "notWord8#"     $ \[Word8V a]            -> pure [Word8V . w . complement $ w8 a]

      -- plusWord8# :: Word8# -> Word8# -> Word8#
  defOp "plusWord8#"    $ \[Word8V a, Word8V b]  -> pure [Word8V . w $ w8 a + w8 b]

      -- subWord8# :: Word8# -> Word8# -> Word8#
  defOp "subWord8#"     $ \[Word8V a, Word8V b]  -> pure [Word8V . w  $ w8 a - w8 b]

      -- timesWord8# :: Word8# -> Word8# -> Word8#
  defOp "timesWord8#"   $ \[Word8V a, Word8V b]  -> pure [Word8V . w  $ w8 a * w8 b]

      -- quotWord8# :: Word8# -> Word8# -> Word8#
  defOp "quotWord8#"    $ \[Word8V a, Word8V b]  -> pure [Word8V . w  $ w8 a `quot` w8 b]  -- NOTE: uint8 / uint8 in C

      -- remWord8# :: Word8# -> Word8# -> Word8#
  defOp "remWord8#"     $ \[Word8V a, Word8V b]  -> pure [Word8V . w  $ w8 a `rem` w8 b]   -- NOTE: uint8 % uint8 in C

      -- quotRemWord8# :: Word8# -> Word8# -> (# Word8#, Word8# #)
  defOp "quotRemWord8#" $ \[Word8V a, Word8V b]  -> pure [Word8V . w $ w8 a `quot` w8 b, Word8V . w $ w8 a `rem` w8 b]

      -- eqWord8# :: Word8# -> Word8# -> Int#
  defOp "eqWord8#"      $ \[Word8V a, Word8V b]  -> pure [IntV $ if a == b then 1 else 0]

      -- geWord8# :: Word8# -> Word8# -> Int#
  defOp "geWord8#"      $ \[Word8V a, Word8V b]  -> pure [IntV $ if a >= b then 1 else 0]

      -- gtWord8# :: Word8# -> Word8# -> Int#
  defOp "gtWord8#"      $ \[Word8V a, Word8V b]  -> pure [IntV $ if a > b  then 1 else 0]

      -- leWord8# :: Word8# -> Word8# -> Int#
  defOp "leWord8#"      $ \[Word8V a, Word8V b]  -> pure [IntV $ if a <= b then 1 else 0]

      -- ltWord8# :: Word8# -> Word8# -> Int#
  defOp "ltWord8#"      $ \[Word8V a, Word8V b]  -> pure [IntV $ if a < b  then 1 else 0]

      -- neWord8# :: Word8# -> Word8# -> Int#
  defOp "neWord8#"      $ \[Word8V a, Word8V b]  -> pure [IntV $ if a /= b then 1 else 0]
