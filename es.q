/ Eratosthenes' sieve
/sieve1:{n:y?1b;(x,n+1;y and count[y]#10b where n,1)}.
/ sieve2:{n:y?1b;(x,n+1;@[y;where count[y]#01b where n,1;:;0b])}.
sieve1:{p:1+y?1b;(x,p;y and count[y]##[p-1;1b],0b)}.
sieve2:{n:1+y?1b;(x,n;@[y;1_-[;1]n*til 1+count[y]div n;:;0b])}.
/ sieve4:{n:1+y?1b;(x,n;raze{.[y;(til count[y]-1;x-1);:;0b]}[n;] n cut y)}.
es:{[f;N] {x,1+where y}. {x>last y 0}[floor sqrt N;] f/(2;0b,"b"$(til N-1)mod 2)}

c:1
primes2:{1+where (floor[sqrt x]-1){c::c+1;$[x[c-1];x and {#[x;1b],#[y-x;]#[x-1;1b],0b}[;count x]c;x]}/0b,1_x#1b}

sum es[sieve1] 2000000
\ts es[sieve1] 2000000
\ts es[sieve2] 2000000
\ts es[sieve3] 2000000
\ts es[sieve4] 2000000
\ts primes2 2000000
/ \ts es[sieve4] 2000000

\
sieve4←{p←1+⍵⍳1 ⋄ (⍺,p) (⍵∧(≢⍵)⍴((p-1)⍴1),0)}