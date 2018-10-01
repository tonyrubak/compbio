# Naive solution
function fib(n)
    if (n == 0 || n == 1)
        1
    else
        fib(n-1) + fib(n-2)
    end
end


# Memoized solution, runs in O(n)
fibs = Dict(0 => 1, 1 => 1)

function fib_memo(n)
    if !(n in keys(fibs))
        x = fibs_memo(n - 2)
        y = fibs_memo(n - 1)
        merge!(fibs, Dict(n => x + y))
    end
    fibs[n]
end

# Dynamic programming solution
function fib_dyn(n)
    x = y = 1
    for i in 1:n
        x, y = y, x + y
    end
    x
end
