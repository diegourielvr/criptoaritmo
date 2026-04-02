%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Servidor - Criptograma DOS + DOS + DOS = SIETE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- use_module(library(socket)).

% =========================================================
%  Logica del criptograma
% =========================================================

dig(0). dig(1). dig(2). dig(3). dig(4).
dig(5). dig(6). dig(7). dig(8). dig(9).

diferentes([]).
diferentes([X|XS]) :-
    maplist(dif(X), XS),
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

% =========================================================
%  Servidor TCP
% =========================================================

servidor :-
    tcp_socket(Socket),
    tcp_bind(Socket, 50000),
    tcp_listen(Socket, 5),
    tcp_open_socket(Socket, In, _Out),
    write('Servidor escuchando en puerto 50000...'), nl,
    add_stream_to_pool(In, doAccept(Socket)),
    stream_pool_main_loop.

doAccept(Socket) :-
    tcp_accept(Socket, SClient, ClientIP),
    tcp_open_socket(SClient, In, Out),
    add_stream_to_pool(In, doService(ClientIP, In, Out)).

doService(ClienteIP, In, Out) :-
    write('Recibi llamada de: '), write(ClienteIP), nl,
    atender(In, Out),
    write('Adios'), nl,
    close(In),
    close(Out),
    delete_stream_from_pool(In).

% Lee comandos uno por uno hasta recibir 'fin'
atender(In, Out) :-
    catch(
        read_term(In, Comando, []),
        _,
        Comando = fin
    ),
    write('Comando recibido: '), write(Comando), nl,
    (   Comando == fin
    ->  true
    ;   manejar(Comando, Respuesta),
        write(Out, Respuesta),
        nl(Out),
        flush_output(Out),
        write('Respuesta enviada: '), write(Respuesta), nl,
        atender(In, Out)
    ).

% =========================================================
%  Manejador de comandos
% =========================================================

manejar(resolver, Respuesta) :-
    (   resolver([D,O,S], [D,O,S], [T,R,E,S], [S,I,E,T,E])
    ->  format(atom(Respuesta),
               'D=~w O=~w S=~w T=~w R=~w E=~w I=~w',
               [D, O, S, T, R, E, I])
    ;   Respuesta = 'sin_solucion'
    ).

manejar(fin, adios).
manejar(_, comando_desconocido).