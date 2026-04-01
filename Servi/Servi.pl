%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Servidor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:-use_module(library(socket)).

servidor:-
    tcp_socket(Socket), 
    tcp_bind(Socket, 50000), 
    tcp_listen(Socket, 5),
    tcp_open_socket(Socket, In, Out),
    add_stream_to_pool(In, doAccept(Socket)),
    stream_pool_main_loop.
        
doAccept(Socket):-
    tcp_accept(Socket, SClient, ClientIP),
    tcp_open_socket(SClient, In, Out),
    add_stream_to_pool(In, doService(ClientIP, In, Out)).

doService(ClienteIP, In, Out):-
    write(' Recibi llamada de: '), write(ClienteIP), nl,
    % Manda Varias cadenas
    repeat,
        read_term(In, L, [variable_names(Nombres)]),
        
        ( L == fin ->
            Verdad = true % Esto permitirá que el repeat termine
        ;
            ( L = (Sumandos, Resultado) -> % Intentamos separar las partes
                ( resolver(Sumandos, Resultado) ->
                    preparar_string(Nombres, StringRes),
                    format(Out, "~w~n", [StringRes]),
                    write(Out, StringRes)
                ;
                    format(Out, "error: sin solucion~n", [])
                )
            ;   % Si el formato enviado no es (S,R) y tampoco es fin
                format(Out, "error: formato invalido~n", [])
            ),
            flush_output(Out),
            Verdad = fail % Forzamos que el repeat vuelva arriba
        ),
    Verdad, % Si Verdad es true, el repeat se detiene
    !,
    write(' Adios '), nl,
    close(In), close(Out),
    delete_stream_from_pool(In).

% Auxiliar para convertir la lista interna de nombres a texto "D=5, O=4..."
preparar_string(Nombres, TextoFinal) :-
    maplist(formato_par, Nombres, Lista),
    atomic_list_concat(Lista, ', ', TextoFinal).

formato_par(Nombre=Var, Atomo) :- 
    format(atom(Atomo), "~w=~w", [Nombre, Var]).

% Practica 4

dig(0).
dig(1).
dig(2).
dig(3).
dig(4).
dig(5).
dig(6).
dig(7).
dig(8).
dig(9).

member(X, [X| _]).
member(X, [_|Ys]) :-
    member(X, Ys).

diferentes([]).
diferentes([X|Xs]) :-
    not(member(X,Xs)),
    diferentes(Xs).

suma(A, B, C, Cin, Res, Cout) :-
    nonvar(A), nonvar(B), nonvar(C), nonvar(Cin),
    Suma is Cin + A + B + C,
    Res is Suma mod 10,
    Cout is Suma div 10.

suma(A, B, C, Cin, Res, Cout) :-
    var(A), dig(A),
    suma(A, B, C, Cin, Res, Cout).

suma(A, B, C, Cin, Res, Cout) :-
    var(B), dig(B),
    suma(A, B, C, Cin, Res, Cout).

suma(A, B, C, Cin, Res, Cout) :-
    var(C), dig(C),
    suma(A, B, C, Cin, Res, Cout).

resolver([[D,O,S], [D,O,S], [T,R,E,S]], [S,I,E,T,E]) :-
    dig(S), S > 0,
    suma(S,S,S,0,E,Cout1),

    dig(O),
    suma(O,O,E,Cout1,T,Cout2),

    dig(D), D > 0,
    dig(R),
    suma(D,D,R,Cout2,E,Cout3),

    dig(T), T > 0,
    suma(0,0,T,Cout3,I,Cout4),

    S = Cout4,

    % Todas las letras deben tener un valor diferente
    diferentes([D,O,S,T,R,E,I]).
