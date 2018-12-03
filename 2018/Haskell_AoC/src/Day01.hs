module Day01
    ( solve
    ) where

inputData :: IO String
inputData = readFile "../data/Day01.data"

solve :: IO ()
solve = inputData >>= (\str -> putStrLn (processData str))

processData :: String -> String
processData = id  

