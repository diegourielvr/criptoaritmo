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
       % Aqui se leen variables, dos en este caso, con punto al final
       read(In,L),read(In,E),
       % Aqui se hacen las consultas de Prolog y se manda la información que
       % se quiera
       (member(E,L), write(Out, yes), put(Out, 13), put(Out, 10);
        not(member(E,L)),write(Out, no), put(Out, 13), put(Out, 10)),
       flush_output(Out),
    L==fin, % Aca terminas, primera variable fin 
    !,
    write(' Adios '), nl,
    close(In), close(Out),
    delete_stream_from_pool(In).

member(X, [X|Xs]).
member(X, [Y|Ys]):-member(X,Ys).
