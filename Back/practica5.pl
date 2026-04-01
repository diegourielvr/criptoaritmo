dig(0). dig(1). dig(2). dig(3). dig(4).

dig(5). dig(6). dig(7). dig(8). dig(9).

diferentes([]).
diferentes([X|XS]) :- 
maplist(dif(X),XS),
diferentes(XS).

resolver([D,O,S], [D,O,S], [T,R,E,S], [S,I,E,T,E]) :-

dig(D), dig(O), dig(S),
dig(T), dig(R), dig(E), dig(S), dig(I),

diferentes([D,O,S,T,R,E,I]), 

D \= 0,
T \= 0,
S \= 0,

Suma1 is S+S+S,
E is Suma1 mod 10,
C1 is Suma1 div 10,

Suma2 is O+O+E+C1,
T is Suma2 mod 10,
C2 is Suma2 div 10,

Suma3 is D+D+R+C2,
E is Suma3 mod 10,
C3 is Suma3 div 10,

Suma4 is T+C3,
I is Suma4 mod 10,
C4 is Suma4 div 10,

S = C4.

