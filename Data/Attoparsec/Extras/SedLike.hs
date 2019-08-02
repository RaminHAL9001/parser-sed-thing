-- | Written by Ramin Honary, 2019-08-02
--
-- Provides a simplified sed-like interface called 'sed' to an Attoparsec 'Parser'.
module Data.Attoparsec.Extras.SedLike where

import           Control.Arrow ((>>>))
import           Control.Monad ((>=>))

import           Data.Monoid
import qualified Data.Text.Lazy       as Lazy
import qualified Data.Text            as Strict

import           Data.Attoparsec.Text.Lazy

----------------------------------------------------------------------------------------------------

-- | 'Strict.Text' from the "Data.Text" module
type StrictText = Strict.Text

-- | 'Lazy.Text' from the "Data.Text.Lazy" module.
type LazyText   = Lazy.Text

-- | The 'sed' function returns a list of these. 'Left' values contain portions of the input string
-- that did not match the given 'Parser', 'Right' values contain portions of the input string that
-- did match, along with the return value of the 'Parser'.
type SedResult a = Either StrictText (StrictText, a)

-- | This is a lazy Text parser (operates on 'Strict.Text' types in the "Data.Text.Lazy" module),
-- but returns strict 'Strict.Text' types (from the "Data.Text" module).
sed :: Parser a -> Parser [SedResult a]
sed p = Lazy.fromStrict <$> takeText >>= loop id where
  scan unmatched instr =
    if Lazy.null instr then return (((Left $ Lazy.toStrict unmatched) :), Lazy.empty) else
      case parse (match p) instr of
        Done remainder a -> return -- Parser succeeded, back to main loop
          ( (if Lazy.null unmatched then id else ((Left $ Lazy.toStrict unmatched) :)) .
            ((Right a) :)
          , remainder
          )
        _                -> -- Parser failed, continue scanning
          scan (unmatched <> Lazy.singleton (Lazy.head instr)) (Lazy.tail instr)
  loop stack = scan Lazy.empty >=> \ (result, remainder) -> do
    stack <- pure $ stack . result
    if Lazy.null remainder then return $ stack [] else loop stack remainder
  
pureSed :: Parser a -> StrictText -> [SedResult a]
pureSed p = parseOnly (sed p) >>> \ case
  Left     msg -> error msg
  Right result -> result
