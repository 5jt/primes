ipf---
title: Finding primes
description: Part I: Functional vector solutions in q for finding prime numbers
authors:
    - Noah Attrup
    - Stephen Taylor
date: September 2021
---
# Finding primes 1: functional solutions 



Finding prime numbers is a compute-intensive task familiar to computer-science students.
It is typically tackled with tightly-iterating algorithms in a language close to the hardware, such as C.
It appears an unrewarding task for a vector-programming language.

It is sometimes said that in Iversonian languages (programming languages derived from Iverson’s notation: e.g. APL, J, k, q) “iteration is free”. Operators and built-in functions iterate implicitly through arrays. They are supplemented by higher-order operators (iterators) that specify more elaborate iteration patterns such as converge, map-reduce and fold.  This has three important, but quite different consequences.

The most obvious consequence is that the writer is relieved of the work of writing loops and can specify common patterns of iteration with one or two symbols.
Code becomes terse. With iteration as subordinated detail the remaining parts of an algorithm become easier to see and study.

Vectors correspond to machine architectures. Algorithms expressed in vectors are more tractable for parallelization. Higher levels of abstraction leave implementors more scope for optimization. This is the second consequence.

The least-remarked consequence is that condensing an algorithm to a few terse lines helps the writer focus on the iteration that it implies or specifies. Arguably, thinking about iteration is easier in an Iversonian language.

At the British APL Association’s 40th anniversary celebration at the Royal Society in London in 2004, implementor Arthur Whitney spoke of k code volumes being two orders of magnitude smaller than C:

> It is theoretically impossible for a k program to outperform hand-coded C, because every k program compiles to a C program that is exactly as fast. Yet k programs routinely outperform hand-coded C. How is this possible? It’s because it is a lot easier to see your errors in four lines of k than in 400 lines of C.

The world does not need new prime numbers, nor even code for finding them.
We offer this article as a close study of efficient vector solutions to problems more usually tackled with less abstract languages. We take the most elementary problems with primes:

-   Is `x` prime?
-   What are the prime numbers up to and including `x`? (In mathematics, this is the $\pi$ function.)
-   What are the prime factors of `x`?

Functional Programming was born from the first Iversonian language, APL, so we begin with purely functional solutions.

No atoms: `x` will always be a vector of ints.


## Is `x` prime?

> A number is prime if it has exactly two positive divisors: itself and 1.

Consider the first twenty integers.

```q
q)n:1+til@ / first x natural numbers
q)show i:n 20
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
```

Every number is divisible by itself and 1. What other positive divisors _might_ it have?

```q
q)i mod n each i
,0
0 0
0 1 0
0 0 1 0
0 1 2 1 0
0 0 0 2 1 0
0 1 1 3 2 1 0
0 0 2 0 3 2 1 0
0 1 0 1 4 3 2 1 0
0 0 1 2 0 4 3 2 1 0
0 1 2 3 1 5 4 3 2 1 0
0 0 0 0 2 0 5 4 3 2 1 0
0 1 1 1 3 1 6 5 4 3 2 1 0
0 0 2 2 4 2 0 6 5 4 3 2 1 0
0 1 0 3 0 3 1 7 6 5 4 3 2 1 0
0 0 1 0 1 4 2 0 7 6 5 4 3 2 1 0
0 1 2 1 2 5 3 1 8 7 6 5 4 3 2 1 0
0 0 0 2 3 0 4 2 0 8 7 6 5 4 3 2 1 0
0 1 1 3 4 1 5 3 1 9 8 7 6 5 4 3 2 1 0
0 0 2 0 0 2 6 4 2 0 9 8 7 6 5 4 3 2 1 0

q)(i; 2=sum each 0=i mod n each i)
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
0 1 1 0 1 0 1 0 0 0  1  0  1  0  0  0  1  0  1  0
```

Above we exploited the iteration implicit in Equal and `mod`, but had to use `each` to iterate `sum` and `n`. 
Would we do better with a lambda and a single iterator?

```q
q)\ts:1000 2=sum each 0=i mod n each i
23 13568
q)\ts:1000 {2=sum 0=x mod n x}each i
32 2432
```

Above, the iteration implicit in `mod` saves time but uses an order of magnitude more memory.
With larger numbers to test, the saving disappears.

```q
q)show R  / random ints
5397760 8463309 3233691 3184915 9057464 4191115 6302698 7578959 893383 5312847
q)\ts 2=sum each 0=R mod n each R
522 2583692800
q)\ts {2=sum 0=x mod n x}each R
476 536871952
```

That gives us our first functional version of _Is `x` prime?_.

```q
q)ipf0:{2=sum 0=x mod n x}'
q)ipf0 R
0000000110b
```

The above illustrates an important development practice. Iversonian languages pioneered the [REPL](https://en.wikipedia.org/wiki/REPL "Wikipedia").

> Develop an algorithm by experiments in the REPL not on one but a _list_ of values.

We can use the [Display](https://code.kx.com/q/ref/display/) operator to instrument our function and observe intermediate values.

```q
q){2=sum 0=x mod 0N!n x}R 0
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29..
0b
```

### Fewer right arguments to `mod`

That’s a long right argument to `mod`. We can reduce it in two ways.

First, if `x` has any divisors, any larger than its square root must be paired with another smaller than its square root. If we find no divisors in `n floor sqrt X`, then `X` is prime.

```q
q)(i; {not 0 in x mod 1 _ n floor sqrt x}each i)
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
1 1 1 0 1 0 1 0 0 0  1  0  1  0  0  0  1  0  1  0
```

1 is a special case, equal to its square root. 

```q
ipf1:{(x<>1)and not 0 in x mod 1 _ n floor sqrt x}
```
```q
q)(i; ipf1 each i)
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
0 1 1 0 1 0 1 0 0 0  1  0  1  0  0  0  1  0  1  0
```

That makes a big difference for big numbers.

```q
q)R 0
5397760
q)\ts:1000 ipf0 1#R 
46696 268436304
q)\ts:1000 ipf1 each 1#R
12 131360
```
The other way we can shorten the right argument to `mod` is by including only prime numbers. 

That suggests some circularity: primeness is what we are testing. It suggests both the possibility of a recursive solution, and also a stateful one. We shall return to these in Part II. 

But an efficient functional primes-to function might make a difference here. 
We’ll return to this question after developing a $\pi$ function.


### Fewer left arguments to `mod`

We can also filter the left argument of `mod`. The value tested above is not prime. We can see that without `mod`, because an even number cannot be prime. Nor can a number ending in 5. Where `x` is above 10 we need test only values ending in 1, 3, 7, or 9.

```q
q)R
5397760 8463309 3233691 3184915 9057464 4191115 6302698 7578959 893383 5312847
```

Only four items of `R` require testing by `mod`. 
We could iterate [Cond](https://code.kx.com/q/ref/cond/).
```q
q){$[last[10 vs x]in 1 3 7 9;ipf1 x;0b]}each R
0000000110b
```
But a dictionary will do the job faster.
```q
q)@'[;R] ({0b};ipf1)0 1 0 1 0 0 0 1 0 1 last 10 vs R
0000000110b

q)\ts:1000 {$[last[10 vs x]in 1 3 7 9;ipf1 x;0b]}each R
101 132320
q)\ts:1000 @'[;R] ({0b};ipf1)0 1 0 1 0 0 0 1 0 1 last 10 vs R
61 132864
```

Extend to small values of `x`:

```q
q)ipf2:{@[;where x in 2 3 5 7;:;1b] @'[;x] ({0b};ipf1)0 1 0 1 0 0 0 1 0 1 last 10 vs x}
q)\ts:1000 ipf1 R
104 131664
q)\ts:1000 ipf2 R
64 133376
```
Filtering suggests [Amend At](https://code.kx.com/q/ref/amend/) rather than a test in each iteration.
But saves us no time.
```q
q)\ts:1000 @[;where R in 2 3 5 7;:;1b] @[count[R]#0b;i;:;ipf1 each R i:where(last 10 vs R)in 1 3 7 9]
68 133248
```

### 
We have unfinished business. If we had a function `pt` (‘primes to’) that returned primes less than its argument we could replace
```q
{(x<>1)and not 0 in x mod 1 _ n floor sqrt x}
```
with 
```q
{(x<>1)and not 0 in x mod 1 _ pt floor sqrt x}'
```
and reduce the right argument to `mod`.

So we turn now to our second task, the $\pi$ function, finding the primes up to `x`.


## Primes to `x` – the $\pi$ function

Our first solution is: select the prime numbers from `n X`.
And we have a test function just written.
```q
q)X:1000
q)i where ipf2 i:n X
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 10..
```
Another simple strategy is to eliminate all the composite numbers.

```q
q){x except raze x*/:\:x}1_i
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 10..
```

This has the virtue of simplicity. By eliminating all multiples of all numbers below `x` the algorithm is obviously correct. But it generates even more composite numbers above `x` than below, and there is a price.

```q
q)\ts i where ipf2 i
1 131968
q)\ts {x except raze x*/:\:x}1_i
51 16794496
```
Sometimes we know values will be small, and simple code outweighs the cost of overcomputing. Not here.
```q
q)ptf0:{x where ipf2 x}n@
q)ptf0 100
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

A quite different strategy is the [Sieve of Eratosthenes](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes "Wikipedia"), which does no arithmetic at all. As we discover primes, we eliminate their multiples from the candidates. 

To find the primes below 100 flag the candidates.
Start by eliminating 1 and the even numbers.

```q
q)show s:0b,99#01b
00101010101010101010101010101010101010101010101010101010101010101010101010101..
```
For convenience, display the candidates as a matrix.
```q
q)see:{10 cut ?[x;1+til count x;0N]}
q)see s
    3   5   7   9
11  13  15  17  19
21  23  25  27  29
31  33  35  37  39
41  43  45  47  49
51  53  55  57  59
61  63  65  67  69
71  73  75  77  79
81  83  85  87  89
91  93  95  97  99
```
The first listed candidate is always prime.
```q
q)1+s?1b
3
```
Eliminate its multiples. And the next. And so on.
```q
q)see s:s and 100#10b where((0N!1+s?1b)-1),1
3
        5   7
11  13      17  19
    23  25      29
31      35  37
41  43      47  49
    53  55      59
61      65  67
71  73      77  79
    83  85      89
91      95  97
q)see s:s and 100#10b where((0N!1+s?1b)-1),1
5
          7
11  13    17  19
    23        29
31        37
41  43    47  49
    53        59
61        67
71  73    77  79
    83        89
91        97
q)see s:s and 100#10b where((0N!1+s?1b)-1),1
7

11  13    17  19
    23        29
31        37
41  43    47
    53        59
61        67
71  73        79
    83        89
          97
```
We can stop here. The next prime, 11, exceeds the square root of 100.
There are no more numbers to eliminate. We found the primes 2 3 5 7, and whatever remains in the sieve.
```q
q)2 3 5 7,1+where s
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

The iteration above fits the [While](https://code.kx.com/q/ref/accumulators#while) pattern.

We begin with a pair of lists: known primes and the sieve flagging the candidates. 
We might start with 2 and the odd numbers as candidates.

```q
q)X:100
q)show is:(2;0b,1_X#10b)  / initial state
2
00101010101010101010101010101010101010101010101010101010101010101010101010101..
```
The sieve finds the next prime, appends it to the list, and removes its multiples from the bitmap. It returns the revised pair.

```q
q){n:1+y?1b;(x,n;y and count[y]#10b where(n-1),1)}. is
2 3
00001010001010001010001010001010001010001010001010001010001010001010001010001..
```
Note the projection of [Apply](https://code.kx.com/q/ref/apply/). It lets the lambda refer to the pair items simply as `x` and `y`.
```q
q)sieve:{n:1+y?1b;(x,n;y and count[y]#10b where(n-1),1)}.
q)3 sieve\is  / the Do iterator
2       001010101010101010101010101010101010101010101010101010101010101010101..
2 3     000010100010100010100010100010100010100010100010100010100010100010100..
2 3 5   000000100010100010100010000010100000100010100010100010000010100000100..
2 3 5 7 000000000010100010100010000010100000100010100010000010000010100000100..
```
When to stop? 

We could stop sieving when we run out of 1s. For that we have the [Converge](https://code.kx.com/q/ref/accumulators/#converge) iterator.
```q
q)({$[any y;[n:1+y?1b;(x,n;y and count[y]#10b where(n-1),1)];(x;y)]}.)\ [is]
2                                                             001010101010101..
2 3                                                           000010100010100..
2 3 5                                                         000000100010100..
2 3 5 7                                                       000000000010100..
2 3 5 7 11                                                    000000000000100..
2 3 5 7 11 13                                                 000000000000000..
2 3 5 7 11 13 17                                              000000000000000..
2 3 5 7 11 13 17 19                                           000000000000000..
2 3 5 7 11 13 17 19 23                                        000000000000000..
2 3 5 7 11 13 17 19 23 29                                     000000000000000..
2 3 5 7 11 13 17 19 23 29 31                                  000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37                               000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41                            000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41 43                         000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47                      000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53                   000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59                000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61             000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67          000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71       000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73    000000000000000..
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 000000000000000..
```
But we don’t need all these iterations! We can stop when we have found 2, 3, 5, and 7.
By then we have eliminated multiples of all the numbers up to the square root of `X`.
Any remaining 1s in the list mark primes.
```q
q)({any z#y}[;;10].)({n:1+y?1b;(x,n;y and count[y]#10b where(n-1),1)}.)\ is
2       001010101010101010101010101010101010101010101010101010101010101010101..
2 3     000010100010100010100010100010100010100010100010100010100010100010100..
2 3 5   000000100010100010100010000010100000100010100010100010000010100000100..
2 3 5 7 000000000010100010100010000010100000100010100010000010000010100000100..
```
That gives us
```q
sieve1:{n:1+y?1b;(x,n;y and count[y]#10b where(n-1),1)}.
es:{[s;N]{x,1+where y}. ({any z#y}[;;floor sqrt N].)s/(2;0b,01b where 1,N-2)}
```
In `es`, `N` is the number up to which to find primes, and `s` is the sieve function. 
(We shall compare some alternatives.)

The test function `{any z#y}[;;floor sqrt N]` checks whether all the candidates up to the square root of `N` have been eliminated. 
Projecting a ternary lambda on `floor sqrt N` binds the test to the square-root. 
The algorithm has just one arithmetic calculation, and it does it just once.

Finally `{x,1+where y}.` combines the list of found primes and the bitmask. 
```q
q)es[sieve1] 100
2 3 4 5 7 11 13 17 19 22 23 26 29 31 34 37 38 41 43 46 47 53 58 59 61 62 67 71 73 74 79 82 83 86 89 94 97
```
Studying `sieve1`, we see each iteration performs an AND between two bitmasks. 
This looks like another array-language ‘overcompute’. 
We actually only need to set certain indexes to false. 
That suggests a sieve that uses [Amend](https://code.kx.com/q/ref/amend/). 
Which is faster? 

* calculate the indexes and amend at them
* AND two bitmasks

```q
q)sieve2:{n:1+y?1b;(x,n;@[y;1_-[;1]n*til 1+count[y]div n;:;0b])}.
q)X:2000000
q)es[sieve1;X]~es[sieve2;X]
1b
q)\ts:100 es[sieve1;X]
4505 18874640
q)\ts:100 es[sieve2;X]
3597 18875088
```
A solid win for Amend over `and`? Not quite: `sieve1` runs faster for smaller values of `X`, and only falls behind with `X` at a million or more.
But `sieve2` works better for the Project Euler challenge.

```q
ptf1:es[sieve2]
```

How does this compare with testing for primes?
Project Euler asks for primes below 2,000,000.

```q
q)\ts ptf0 2000000
4538 486540304
q)\ts ptf1 2000000
43 8391088
```
Eratosthenes wins by two orders of magnitude. 


## The test revisited

Now we have an efficient $\pi$ function, can we use it to improve our test, by using only primes as the right argument of `mod`?
Recall when testing for primeness we saw the possibility of replacing `x mod 1_ n floor sqrt x` with `x mod 1_ pt floor sqrt x`, where `pt` is the $\pi$ or primes-to function. 
Perhaps it’s faster to find the primes than to calculate the `mod`s with non-primes?
```q
ipf1:{(x<>1)and not 0 in x mod 1 _ n floor sqrt x}
ipf2:{@[;where x in 2 3 5 7;:;1b] @'[;x] ({0b};ipf1)0 1 0 1 0 0 0 1 0 1 last 10 vs x}

ipf3:{(x<>1)and not 0 in x mod 1 _ ptf1 floor sqrt x}
ipf4:{@[;where x in 2 3 5 7;:;1b] @'[;x] ({0b};ipf3)0 1 0 1 0 0 0 1 0 1 last 10 vs x}
```
```q
q)\ts:10000 ipf2 R
697 131808
q)\ts:10000 ipf4 R
2863 131920
```
No such luck.
But perhaps, if we did not have to compute the result of $\pi \sqrt[N]$ for each test? 
If we knew all the primes up to two million?

---
In the next parts of this article we shall look at prime decomposition, and at how the functional solutions can be improved with state.