## Stateful solutions

> Organized people are just too lazy to look for things.

Let’s remember the primes we find so we do not have to look for them again. 
Our memory can take the form of two globals: a list of known primes and the highest number below which we have searched.

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

**See Issue #1**


We can replicate with state the filtering of `ipf2`.

```q
ips2:{@[;where x in 2 5;:;1b] @[count[x]#0b;i;:;ips1 x i:where(last 10 vs x)in 1 3 7 9]}
```


