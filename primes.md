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

A number is prime if it divisible only by itself and 1. 

```q
q)i:1+til 20
q)ipf0:{not 0 in min x mod 2_til x}
q)(i;ipf0 each i)
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
1 1 1 0 1 0 1 0 0 0  1  0  1  0  0  0  1  0  1  0
```

On reflection, that `2_til x` could be improved. The right argument of `mod` needs no items higher than the square root of `x+1`.

```q
q)ipf1:{not 0 in min x mod 2_til ceiling sqrt x+1}
q)(i;ipf1 each i)
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
1 1 1 0 1 0 1 0 0 0  1  0  1  0  0  0  1  0  1  0
```

For larger values of `x` the improvement is substantial.

```q
q)show q:first 1?10000000
1778945
q)\ts ipf0 q
34 67109056
q)\ts ipf1 q
0 65728
```

