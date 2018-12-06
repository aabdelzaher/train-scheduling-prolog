:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).
:- use_module(library(clpfd)).

:- http_handler(root('.'), handle, []).


server(Port) :-
    http_server(http_dispatch, [port(Port)]).


handle(Request) :-
    cors_enable(Request,
        [ methods([get,post,delete])
    ]),
    format(user_output,"I am here~n",[]),
    http_read_json(Request, DictIn),
    format(user_output,"Request is: ~p~n",[Request]),
    format(user_output,"DictIn is: ~p~n",[DictIn]),
    DictIn=json([x=X,y=Y,z=Z]),
    solve(X,Y,Z,Plan),
    reply_json(json([plan=Plan])).


solve(X,Y,Z,Plan):-
    retractall(maxNodes(_)),
    retractall(mat(_)),
    retractall(cntMat(_)),
    assertz(maxNodes(X)),
    assertz(mat(Y)),
    assertz(cntMat(Z)),
    solveProblem([2,1],[1,3],[1,1],[2,3],Plan,D).


adj(X,Y,Val):-
    mat(AdjMat),
    maxNodes(Max),
    length(Edges, Max),
    element(X, Edges, 0),
    tuples_in([Edges], AdjMat),
    element(Y, Edges, Val).

cntAdj(X,Y,Val):-
    cntMat(CntMat),
    maxNodes(Max),
    length(Edges, Max),
    element(X, Edges, 0),
    tuples_in([Edges], CntMat),
    element(Y, Edges, Val).

path(X, X, [X], 0, N):-
    maxNodes(N).
path(X,Y,Path,Cost,Length):-
    Path=[X|T],
    maxNodes(Max),
    Length#<Max,
    Z in 1..Max,
    Length2 #= Length + 1,
    mat(AdjMat),
    length(Edges, Max),
    element(X, Edges, 0),
    tuples_in([Edges], AdjMat),
    element(Z, Edges, C1),
    path(Z,Y,T,C2,Length2),
    Cost #= C1 + C2.


remove_duplicates([],[]).
remove_duplicates([H|T],[H|T2]):-
    remove_duplicates(T,T2),
    \+member(H,T2).
remove_duplicates([H|T],T2):-
    remove_duplicates(T,T2),
    member(H,T2).


getPath(X,Y,Ret):-
    path(X,Y,Path,Cost,1),
    once(labeling([min(Cost)],Path)),
    remove_duplicates(Path,Ret).

getPlan([_],[],[],[],[],[],1000).
getPlan(Path,From,To,In,Out,Edge,T1):-
    [T1,T2] ins 1..1000,
    Path=[X,Y|T],
    From=[X|From2],
    To=[Y|To2],
    In=[T1|In2],
    Out=[T2|Out2],
    Edge=[E|Edge2],
    adj(X,Y,Val),
    cntAdj(X,Y,MaxE),
    E in 1..MaxE,
    T2#=T1+Val,
    T2#=<Min2,
    getPlan([Y|T],From2,To2,In2,Out2,Edge2,Min2).

solve1(X,Y,From,To,In,Out,Edge,MinTime):-
    getPath(X,Y,Path),
    getPlan(Path,From,To,In,Out,Edge,MinTime).

% getLast([X],X).
% getLast([_,Y|T],L):-
%     getLast([Y|T],L).

% S1, S2, Release Time, Due Time, Plan , Total Delay
solveAll([],[],[],[],[],0).
solveAll([H1|T1],[H2|T2],[H3|T3],[H4|T4],[H5|T5],TotalDelay):-
    solve1(H1,H2,From,To,In,Out,Edge,MinTime),
    last(Out,Max),
    Delay #=abs(Max-H4),
    MinTime#>=H3,
    TotalDelay#=Delay+Delay2,
    H5=[From,To,In,Out,Edge], % This is a single element of Plan, every element here is a list
    solveAll(T1,T2,T3,T4,T5,Delay2).

collectOne(_,_,_,_,[[],_,_,_,_],[],[]).
collectOne(X,Y,L,R,[[X|T1],[Y|T2],[H3|T3],[_|T4],[H5|T5]],S,D):-
    H5#>=L #<==> M1,
    H5#=<R #<==> M2,
    M #=M1*M2,
    adj(X,Y,Val), % to be passed to avoid calling many times
    Val2 #=Val*M,
    S=[H3|S2],
    D=[Val2|D2],
    collectOne(X,Y,L,R,[T1,T2,T3,T4,T5],S2,D2).

% collectOne(X,Y,1,1,[[X|T1],[Y|T2],[_|T3],[_|T4],[2|T5]],S,D):-
%     collectOne(X,Y,1,1,[T1,T2,T3,T4,T5],S,D).
% collectOne(X,Y,2,2,[[X|T1],[Y|T2],[_|T3],[_|T4],[1|T5]],S,D):-
%     collectOne(X,Y,2,2,[T1,T2,T3,T4,T5],S,D).

collectOne(X,Y,L,R,[[X|T1],[H2|T2],[_|T3],[_|T4],[_|T5]],S,D):-
    H2#\=Y,
    collectOne(X,Y,L,R,[T1,T2,T3,T4,T5],S,D).
collectOne(X,Y,L,R,[[H1|T1],[Y|T2],[_|T3],[_|T4],[_|T5]],S,D):-
    H1#\=X,
    collectOne(X,Y,L,R,[T1,T2,T3,T4,T5],S,D).
collectOne(X,Y,L,R,[[H1|T1],[H2|T2],[_|T3],[_|T4],[_|T5]],S,D):-
    H1#\=X,
    H2#\=Y,
    collectOne(X,Y,L,R,[T1,T2,T3,T4,T5],S,D).
    
    
    
collect(_,_,_,_,[],[],[]).
collect(X,Y,L,R,[H|T],Start,Duration):-
    collectOne(X,Y,L,R,H,S1,D1),
    collect(X,Y,L,R,T,S2,D2),
    append(S1,S2,Start),
    append(D1,D2,Duration).

generate10([],[]).
generate10([_|T],[10|T2]):-
    generate10(T,T2).

validate(X,Y,Plan):-
    collect(X,Y,1,2,Plan,Start, _),
    generate10(Start,Duration),
    serialized(Start, Duration).

validateAll([],[],_).
validateAll([H1|T1],[H2|T2],Plan):-
    validate(H1,H2,Plan),
    validateAll(T1,T2,Plan).

min(A,B,R):-
    A#<B #<==> AGB,
    B#=<A #<==> BGA,
    R#= AGB*A + BGA*B.

validate4(_,[],_,_).
validate4(X,[H|T],D1,[H1|T1]):-
    % S=[X,H],
    % D=[D1,H1],
    % serialized(S,D),
    min(D1,H1,Min),
    abs(H-X)#>=Min,
    validate4(X,T,D1,T1).

validate3([],_,_,_).
validate3([H|T],Start2,[H1|T1],D2):-
    validate4(H,Start2,H1,D2),
    validate3(T,Start2,T1,D2).

validate2(X,Y,E,Plan):-
    collect(X,Y,E,E,Plan,Start1,D1),
    collect(Y,X,E,E,Plan,Start2,D2),
    validate3(Start1,Start2,D1,D2).


validateAll2([],[],_).
validateAll2([H1|T1],[H2|T2],Plan):-
    validate2(H1,H2,1,Plan),
    validate2(H1,H2,2,Plan),
    validateAll2(T1,T2,Plan).


generate(X,_,[],[]):-
    maxNodes(Max),
    X #>Max.
generate(X,Y,[X|T1],[Y|T2]):-
    maxNodes(Max),
    X#=<Max,
    Y#<Max,
    Y1#=Y+1,
    generate(X,Y1,T1,T2).
generate(X,Max,[X|T1],[Max|T2]):-
    maxNodes(Max),
    X#=<Max,
    X1 #=X+1,
    generate(X1,1,T1,T2).


solveProblem(S1,S2,Release,Due,Plan,TotalDelay):-
    solveAll(S1,S2,Release,Due,Plan,TotalDelay),
    generate(1,1,L1,L2),
    validateAll(L1,L2,Plan),
    validateAll2(L1,L2,Plan),
    flatten(Plan,X),
    labeling([min(TotalDelay)],X).


