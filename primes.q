/ # prime numbers

/ ## functional solutions

/ ### is x prime?
ipf0:{2=sum 0=x mod 1_ til 1+x}'
ipf1:{(x<>1)and not 0 in x mod 2_til 1+floor sqrt x}'
ld:{last 10 vs x} / last digits
ipf2:{@[;where x in 2 5;:;1b] @[count[x]#0b;i;:;ipf1 x i:where(ld x)in 1 3 7 9]}

/ ### prime numbers to x
/ simple but overcomputes
ptf0:`s#{x except raze x*\:/:x}1_1+til@

/ Eratosthenes' sieve
sieve1:{p:1+y?1b;(x,p;y and count[y]##[p-1;1b],0b)}.
sieve2:{n:1+y?1b;(x,n;@[y;1_-[;1]n*til 1+count[y]div n;:;0b])}.
es:{[f;N] {x,1+where y}. {x>last y 0}[floor sqrt N;] f/(2;0b,"b"$(til N-1)mod 2)}
ptf1:es[sieve2]


/ ## solutions with state

/ ### prime numbers to x
KP:`s#2 3 5 7  / known primes
PT:10           / to 10
pts0:{$[x<=PT; KP where KP<=x; KP::`s#ptf1 PT::x]}

/ ### is x prime?
ips1:{(x<>1)and not 0 in x mod pts0 floor sqrt x}
ips2:{@[;where x in 2 5;:;1b] @[count[x]#0b;i;:;ips1 each x i:where(ld x)in 1 3 7 9]}
ips3:{@[;where x in 2 5;:;1b] ({0b};ips1)[0 1 0 1 0 0 0 1 0 1 ld x]@'x}
ips4:{@[;where x in 2 5;:;1b] ({0b};ips1)[ld[x]in 1 3 7 9]@'x}

/


ess:{[f;N]`s#{x,1+where y}. {x>last y 0}[ceiling sqrt N;] f/(KP;0b,1_min N#'((KP-1)#'1b),'0b)} 

pts0:{$[x<=PT; KP where KP<=x; KP::ess[sieve4]PT::x]}
pts1:{$[x<=PT; KP where KP<=x; KP::es[sieve4]PT::x]}


/
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
