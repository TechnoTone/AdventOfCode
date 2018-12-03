module Day01
    ( solve
    ) where

inputData :: IO String
inputData = readFile "../data/Day01.data"

solve :: IO ()
solve = inputData >>= (\str -> putStrLn (amazingPureFunction str))

amazingPureFunction :: String -> String
amazingPureFunction = id  


