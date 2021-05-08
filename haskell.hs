-- упражнения https://cmc-msu-ai.github.io/haskell-course/lecture/2013/09/03/quick-start.html
my_factorial x = if x <= 1 then 1 else my_factorial(x-1) * x
my_remove_second x = head x : tail(tail x)
my_last x = last x
my_reverse x = if null x then x else my_reverse(tail x) ++ [head x]

main =
    do
        putStrLn("=== Глава 1 ===")
        print(my_factorial 5)
        print(my_last [1, 2, 3, 4, 5])
        print(my_remove_second [1, 2, 3, 4])
        print(my_remove_second "Hi")
        print(my_last "Hello!")
        print(my_reverse [1, 2, 3, 4, 5])
