/ # prime numbers

/ ## functional solutions

/ ### is x prime?
/ atom argument
ip0:{$[x=2;1b;not 0 in min x mod 2_til 1+ceiling sqrt x]}
/ atomic for function on atom of type
atomic:{[fun;typ;dat]t:type dat;$[t in 0h,typ;.z.s each dat;t=neg typ;fun dat;'type]}
/ atomic for function on vector of type
vector:{[fun;typ;dat]t:type dat;$[t=0h;.z.s each dat;t=typ;fun dat;t=neg typ;first fun(),dat;'type]}
/ atomic on long ints - naive
/ ipf0:{t:type x;$[t in 0 7h;.z.s each x;t=-7h;ip0 x;'type]}
ipf0:atomic[ip0;7h]
/ vector of ints – filtered test
ipf1:{
  i:where big:x>10;
  i:where@[count[x]#0b;i;(last 10 vs x i)in 1 3 7 9];
  r:@[count[x]#0b;i;:;ip0 peach x i];
  i:where not big;
  @[r;i;:;(x i)in 1 2 3 5 7] }
ipf2:vector[ipf1;7h]

/ ### prime numbers to x
/ simple but overcomputes
ptf0:`s#{x except raze x*\:/:x}1_1+til@
/ Eratosthenes' sieve
es:{[f;N]`s#{x,1+where y}. {x>last y 0}[ceiling sqrt N;] f/(2;0b,1_N#10b)} 
sieve4:{p:1+?[;1b]x[1];(x[0],p;x[1] and #[count x 1;]#[p-1;1b],0b)}
ptf1:es[sieve4]

/ ## solutions with state

/ ### prime numbers to x
KP:asc 2 3 5 7  / known primes
PT:10           / to 10
ess:{[f;N]`s#{x,1+where y}. {x>last y 0}[ceiling sqrt N;] f/(KP;0b,1_min N#'((KP-1)#'1b),'0b)} 

pts0:{$[x<=PT; KP where KP<=x; KP::ess[sieve4]PT::x]}
pts1:{$[x<=PT; KP where KP<=x; KP::es[sieve4]PT::x]}