---
title: Finding primes
description: Vector programming solutions for finding prime numbers
authors:
    - Noah Attrup
    - Stephen Taylor
date: July 2021
---
# Finding primes



Finding prime numbers is a compute-intensive task familiar to students.
It is typically tackled with tightly-iterating algorithms in a language close to the hardware, such as C.
It would seem an unrewarding task for a vector-programming language.

It is sometimes said that in the programming languages derived from Iverson’s notation (APL, J, k, q) “iteration is free”. Operators and built-in functions iterate implicitly through arrays. They are supplemented by higher-order operators (iterators) that specify more elaborate iteration patterns such as converge, map-reduce and fold.  This has three important, but quite different consequences.

The most obvious is that the writer is relieved of the work of writing loops and can specify common patterns of iteration with one or two symbols.
Code becomes terse. Whith iteration subordinated as detail the remaining parts of an algorithm become easier to see and study.

Vectors correspond to machine architectures. Algorithms expressed in vectors are more tractable for parallelization. Higher levels of abstraction leave implementors more scope for optimization. This is the second consequence.

The least-remarked consequence is that condensing an algorithm to a few terse lines helps the writer focus on the iteration that it implies or specifies.

At the British APL Association’s 40th anniversary celebration at the Royal Society in London in 2004, implementor Arthur Whitney spoke of k code volumes being two orders of magnitude smaller than C:

> It is theoretically impossible for a k program to outperform hand-coded C, because every k program compiles to a C program that is exactly as fast. Yet k programs routinely outperform hand-coded C. How is this possible? It’s because it is a lot easier to see your errors in four lines of k than in 400 lines of C.

The world does not need new prime numbers, nor even code for finding them.
We offer this article as a close study of efficient vector solutions to problems more usually tackled with less abstract languages. We take the most elementary problems with primes:

-   Is `x` prime?
-   What are the prime numbers up to (and including) `x`?
-   What are the prime factors of `x`?


## Functional solutions

Functional Programming was born from the first Iversonian language, APL, so we begin with purely functional solutions.
(Solutions that involve state we shall amuse ourselves by calling _stately_.)

No atoms: `x` will always be a vector of ints.


### Is `x` prime?

!!! info "A number is prime if it has exactly two positive divisors: itself and 1."

Consider the first twenty integers.

```q
q)show i:1+til 20
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
```

Every number is divisible by itself and 1. What other positive divisors _might_ it have?

```q
q)i mod 1+til each i
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

q)(i; 2=sum each 0=i mod 1+til each i)
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
0 1 1 0 1 0 1 0 0 0  1  0  1  0  0  0  1  0  1  0
```

Above we exploited the iteration implicit in Equals and `mod`, but had to use `each` to iterate `sum` and `til`. 
Would we do better with a lambda and a single iterator?

```q
q)\ts:1000 2=sum each 0=i mod 1+til each i
23 13568
q)\ts:1000 {2=sum 0=x mod 1+til x}each i
32 2432
```

Above, implicit iteration saves time but uses an order of magnitude more memory.
With larger numbers to test, the saving disappears.

```q
q)show R  / random ints
5397760 8463309 3233691 3184915 9057464 4191115 6302698 7578959 893383 5312847
q)\ts 2=sum each 0=R mod 1+til each R
522 2583692800
q)\ts {2=sum 0=x mod 1+til x}each R
476 536871952
```

That gives us our first version.

```q
ipf0:{2=sum 0=x mod 1+til x}'
```
```q
q)ipf0 R
0000000110b
```

The above illustrates an important development practice. Iversonian languages pioneered the [REPL](https://en.wikipedia.org/wiki/REPL "Wikipedia".

!!! note "Develop an algorithm by experiments in the REPL not on one but a _list_ of values."

We can use the internal function `0N!` to instrument our function and observe intermediate values.

```q
q){2=sum 0=x mod 0N!1+til x}R 0
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29..
0b
```

That’s a long right argument to `mod`. We can reduce it in two ways.

First, if `x` has any divisors it must have at least two, of which at least one can be no larger than the square root of `x`. So we can test a shorter list.
Since the shorter list omits `x` we are looking for a single 0 in the result of `mod`.

```q
q)(i; {not 0 in x mod 1_1+til floor sqrt x}each i)
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
1 1 1 0 1 0 1 0 0 0  1  0  1  0  0  0  1  0  1  0
```

1 is a special case, equal to its square root. 

```q
ipf1:{(x<>1)and not 0 in x mod 1_1+til floor sqrt x}'
```
```q
q)(i; ipf1 i)
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
0 1 1 0 1 0 1 0 0 0  1  0  1  0  0  0  1  0  1  0
```

That makes a big difference for big numbers.

```q
q)R 0
5397760
q)\ts:1000 ipf0 1#R 
46696 268436304
q)\ts:1000 ipf1 1#R
12 131360
```

The other way we can shorten the right argument to `mod` is by including only prime numbers. That entails some circularity: primeness is what we are testing. It suggests both the possibility of a recursive solution, and also a stately one. We shall return to these. 

We can also filter the left argument of `mod`. The value of `q` tested above is not prime. We can see that without `mod`, because an even number cannot be prime. Nor can a number ending in 5. Where `x` is above 10 we need test only values ending in 1, 3, 7, or 9.

```q
q)R
5397760 8463309 3233691 3184915 9057464 4191115 6302698 7578959 893383 5312847
```

Only four items of `R` require testing by `mod`. 

```q
q){$[0N!last[10 vs x]in 1 3 7 9;ipf1 x;0b]}each R
0b
1b
1b
0b
0b
0b
0b
1b
1b
1b
0000000110b
```

Including small values of `x`:

```q
q)\ts:1000 ipf1 R
104 131664
q)\ts:1000 {$[x in 2 3 5 7;1b;last[10 vs x]in 1 3 7 9;ipf1 x;0b]}each R
97 131648
```

Disappointing! What we save by testing only four of the items of `R` is mostly offset by the filtering. 

But the concept of filtering suggests [Amend At](https://code.kx.com/q/ref/amend/) rather than a test in each iteration.

```q
q)\ts:1000 @[count[R]#0b;i;:;ipf1 R i:where(last 10 vs R)in 1 3 7 9]
60 132624
```

The filter eliminates multiples of 2 and 5, so we need to correct for 2 and 5 themselves.

```q
ipf2:{@[;where x in 2 5;:;1b] @[count[x]#0b;i;:;ipf1 x i:where(last 10 vs x)in 1 3 7 9]}
```
```q
q)\ts:1000 ipf1 R
111 131584
q)\ts:1000 ipf2 R
62 131680
```

We have unfinished business. If we had a function `pt` that returned primes less than its argument we could replace

```q
ipf1:{(x<>1)and not 0 in x mod 1_1+til floor sqrt x}'
```

with 

```q
ipf1:{(x<>1)and not 0 in x mod 1_1+pt floor sqrt x}'
```

and reduce the right argument to `mod`.

We turn now to our second task: finding all the primes less than `x`.


### Primes below `x`

We have a simple way to find the primes below `x`: test all the numbers below it.

```q
q)i where ipf2 i:1+til 1000
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 10..
```

Another simple strategy is eliminate all the composite numbers.

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

Sometimes we know values will be small and simple code outweighs the cost of overcomputing. Not here.

```q
ptf0:{x where ipf2 x}1+til@
```
```q
q)ptf0 100
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

A quite different strategy is the [Sieve of Eratosthenes](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes "Wikjipedia), which requires no division at all. As we discover primes, we eliminate their multiples from the candidates. 

To find the primes below 100 flag the candidates: the numbers to 100 that might be prime.
The only number we know is not prime is 1.

```q
q)show s:01b where 1 99
01111111111111111111111111111111111111111111111111111111111111111111111111111..
```

For convenience, display the candidates as a matrix.

```q
q)see:{10 10#("j"$x)'[0N;1+til 100]}
q)see s
   2  3  4  5  6  7  8  9  10
11 12 13 14 15 16 17 18 19 20
21 22 23 24 25 26 27 28 29 30
31 32 33 34 35 36 37 38 39 40
41 42 43 44 45 46 47 48 49 50
51 52 53 54 55 56 57 58 59 60
61 62 63 64 65 66 67 68 69 70
71 72 73 74 75 76 77 78 79 80
81 82 83 84 85 86 87 88 89 90
91 92 93 94 95 96 97 98 99 100
```

The first prime is 2. 

```q
q)i s?1b
2
```

Eliminate its multiples. And the next. And so on.

```q
q)see s:s&100#10b where((0N!1+s?1b)-1),1
2
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
q)see s:s&100#10b where((0N!1+s?1b)-1),1
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
q)see s:s&100#10b where((0N!1+s?1b)-1),1
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
q)see s:s&100#10b where((0N!1+s?1b)-1),1
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

We begin with two lists: known primes and the sieve flagging the candidates. 
We might start with 2 and the odd numbers as candidates.

```q
q)X:100
q)show is:(2;0b,1_X#10b)  / initial state
2
00101010101010101010101010101010101010101010101010101010101010101010101010101..`
```

To sieve is to take the next prime, append it to the lis, and remove its multiples from the bitmap – and return the revised pair.

```q
q){n:1+y?1b;(x,n;y&count[y]#10b where(n-1),1)}. is
2 3
00001010001010001010001010001010001010001010001010001010001010001010001010001..
```

Note the use of [Apply](https://code.kx.com/q/ref/apply/) that lets the lambda refer to the items of the pair simplay as `x` and `y`.

```q
sieve:{n:1+y?1b;(x,n;y&count[y]#10b where(n-1),1)}.
```
```q
q)3 sieve\is
2       001010101010101010101010101010101010101010101010101010101010101010101..
2 3     000010100010100010100010100010100010100010100010100010100010100010100..
2 3 5   000000100010100010100010000010100000100010100010100010000010100000100..
2 3 5 7 000000000010100010100010000010100000100010100010000010000010100000100..
```

When to stop? We should continue to apply `sieve` while the next prime is less than the square root of `X`. 

```q
q){x>y[1]?1b}[floor sqrt X] sieve/is
2 3 5 7
00000000001010001010001000001010000010001010001000001000001010000010001010000..
q){x,1+where y}.{x>y[1]?1b}[floor sqrt X] sieve/is
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
```

Writing as a function of `X`:

```q
ptf1:{{x,1+where y}.{x>y[1]?1b}[floor sqrt x] sieve/(2;0b,1_x#10b)}
```

How does this compare with testing the candidates ending in 1 3 7 9 as primes?
Project Euler asks for primes below 2,000,000.

```q
q)\ts ptf0 2000000
4538 486540304
q)\ts ptf1 2000000
43 8391088
```

Eratosthenes wins by two orders of magnitude. 


## Stately solutions

Let’s remember the primes we find so we do not have to look for them again. 
Our memory can take the form of two globals: a list of known primes and the highest number below which we  have searched.

```q
KP:`s#2 3 5 7  / known primes
PT:10          / to 10
```

We assign the _sorted_ attribute to the list because it helps the interpreter search it.

Now we have two ways to produce the primes to `x`: select them or find them.

```q
q)KP
`s#2 3 5 7
q)\ts {$[x<=PT; KP where KP<=x; KP::ptf1 PT::x]}2000000
41 8391968
q)\ts {$[x<=PT; KP where KP<=x; KP::ptf1 PT::x]}2000000
0 4195328
q)KP
2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 10..
```

```q
pts0:{$[x<=PT; KP where KP<=x; KP::ptf1 PT::x]}
```

Can we save time by _extending_ `KP` rather than regenerating it? 
That is, can we make the initial state to be sieved the value of `KP` and a bitmap derived from it? 

We certainly can, and deriving the bitmap is not hard.

```q
q)is:(KP;min X#'(10b@ where@)each(KP-1),'1)
```

But it turns out to be far quicker – far, _far_ quicker, and more space-efficient – to let the sieve build the bitmap.

<!-- 
Now we have an efficient method for finding primes, and remember them, we can revisit the test for whether `x` is prime.

Clearly, any items of `x` below `PT` can simply be tested for whether they are in `KP`. 

```q
ips0:{@[;nb;:;x[nb:where not big]in KP] @[count[x]#0b;b;:;ipf2 x b:where big:x>PT]}
```
```q
q)PT
4000000
q)R2:500000?10000000
q)\ts ipf2 R2
2188 117441520
q)\ts ips0 R2
1590 126355520
```

Two filters are applied here. Only numbers above `PT` are passed to `ipf2`, which then passes to `ipf1` only numbers ending in 1, 3, 7, or 9. 
 -->
We noted earlier that in `ipf1` the right argument to `mod` could be shortened by substituting `pt` for `til`. We are now in a position to do that.

```q
ips1:{(x<>1)and not 0 in x mod pts0 floor sqrt x}'
```
```q
q)\ts ipf1 R2
5305 12718720
q)\ts ips1 R2
1578 126354544
```

The comparison above omits any filtering. 
The better performance comes entirely from passing only primes as the right argument to `mod`.

We can replicate with state the filtering of `ipf2`.

```q
ips2:{@[;where x in 2 5;:;1b] @[count[x]#0b;i;:;ips1 x i:where(last 10 vs x)in 1 3 7 9]}
```


