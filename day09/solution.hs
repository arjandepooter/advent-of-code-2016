import Text.Parsec
  ( anyChar,
    between,
    char,
    count,
    digit,
    eof,
    getInput,
    many1,
    runParser,
    setInput,
    (<|>),
  )
import Text.Parsec.String (Parser)

data Block = RepeatedBlock Int [Block] | Block Char deriving (Show)

blockLength :: Block -> Int
blockLength (Block s) = 1
blockLength (RepeatedBlock c blocks) = c * sum (fmap blockLength blocks)

int :: Parser Int
int = read <$> many1 digit

regularBlock :: Parser Block
regularBlock = Block <$> anyChar

repeatData :: Parser (Int, Int)
repeatData = do
  len <- int
  char 'x'
  cnt <- int
  return (len, cnt)

partial :: Int -> Parser a -> Parser a
partial n p = do
  input <- getInput
  setInput (take n input)
  r <- p
  setInput (drop n input)
  return r

repeatedBlock :: Parser Block
repeatedBlock = do
  (len, cnt) <- between (char '(') (char ')') repeatData
  s <- fmap Block <$> count len anyChar
  return (RepeatedBlock cnt s)

repeatedBlock2 :: Parser Block
repeatedBlock2 = do
  (len, cnt) <- between (char '(') (char ')') repeatData
  s <- partial len blocks2
  return (RepeatedBlock cnt s)

block :: Parser Block
block = repeatedBlock <|> (Block <$> anyChar)

block2 :: Parser Block
block2 = repeatedBlock2 <|> (Block <$> anyChar)

blocks :: Parser [Block]
blocks = many1 block <* eof

blocks2 :: Parser [Block]
blocks2 = many1 block2 <* eof

main = do
  line <- getLine

  let a = runParser blocks () "" line
  print $
    case a of
      Left pe -> error (show pe) 0
      Right bls -> sum $ fmap blockLength bls

  let b = runParser blocks2 () "" line
  print $
    case b of
      Left pe -> error (show pe) 0
      Right bls -> sum $ fmap blockLength bls

  return ()