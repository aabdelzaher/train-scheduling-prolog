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

% This is a predicate that solves the problem,it succeeds if X:Number of Nodes of the graph, Y: 2D array representing the adjacency
% matrix of the graph, Z: count Matrix where Z[i,j] is 0 if there is no edge between i and j, 1 if there is 1 edge between i and j
% and 2 if there are two edges between i and j
% Plan is a valid plan according to the description in the report
solve(X,Y,Z,Plan):-
    retractall(maxNodes(_)),
    retractall(mat(_)),
    retractall(cntMat(_)),
    assertz(maxNodes(X)),
    assertz(mat(Y)),
    assertz(cntMat(Z)),
    solveProblem([2,1],[1,3],[1,1],[2,3],Plan,D).

%this predicate succeds if the length of the edge between node X and node Y is Val
adj(X,Y,Val):-
    mat(AdjMat),
    maxNodes(Max),
    length(Edges, Max),
    element(X, Edges, 0),
    tuples_in([Edges], AdjMat),
    element(Y, Edges, Val).

%this predicate succeds if the count pod edges between node X and Node Y is Val. It has a value of 0,1 or 2
cntAdj(X,Y,Val):-
    cntMat(CntMat),
    maxNodes(Max),
    length(Edges, Max),
    element(X, Edges, 0),
    tuples_in([Edges], CntMat),
    element(Y, Edges, Val).

%this predicate succeeds if the shortest path between node X and node Y is Path, with Cost = C and with length =< Length
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

%this predicate succeeds if the second argument is the path in the first argument but after removing the duplicates (if it takes some
% self loops)
remove_duplicates([],[]).
remove_duplicates([H|T],[H|T2]):-
    remove_duplicates(T,T2),
    \+member(H,T2).
remove_duplicates([H|T],T2):-
    remove_duplicates(T,T2),
    member(H,T2).

%this predicate gets the path Ret which is the shortest path between the nodes X, Y after removing the duplicates
getPath(X,Y,Ret):-
    path(X,Y,Path,Cost,1),
    once(labeling([min(Cost)],Path)),
    remove_duplicates(Path,Ret).
% this predicate succeeds if Path is a sequence of nodes, From and To are two lists representing pairs of every consecutive nodes in
% the path for example if the Path is [1,2,4,5] --> From = [1,2,4] and To = [2,4,5], In is a list of timings the trains will leave every
% corresponding node in the list From and Out is a list of timings where the train will leave nodes in the list To,
%and T1 is the time the train has left the last node
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
% this predicate succeeds if [From,To,In,Out] is a Plan (which is explained in the report) for the train travelling from node X to node Y and Edge[i] represents which
% edge is chosen (edge 1 or 2) in the path between From[i] and To[i], and minTime is the time where the train will start its trip after
solve1(X,Y,From,To,In,Out,Edge,MinTime):-
    getPath(X,Y,Path),
    getPlan(Path,From,To,In,Out,Edge,MinTime).

% getLast([X],X).
% getLast([_,Y|T],L):-
%     getLast([Y|T],L).

% The predicate solveAll(S1, S2, Release Time, Due Time, Plans , Total Delay) it calls solve1 predicate for each train represented in
% list S1 and S2 with release time and due time in lists Release Time and Due Time and accumulates a list of Plans for each train
% in the Plans List and TotalDelay is the summation of delays of the trains from their sue time
solveAll([],[],[],[],[],0).
solveAll([H1|T1],[H2|T2],[H3|T3],[H4|T4],[H5|T5],TotalDelay):-
    solve1(H1,H2,From,To,In,Out,Edge,MinTime),
    last(Out,Max),
    Delay #=abs(Max-H4),
    MinTime#>=H3,
    TotalDelay#=Delay+Delay2,
    H5=[From,To,In,Out,Edge], % This is a single element of Plan, every element here is a list
    solveAll(T1,T2,T3,T4,T5,Delay2).
% This predicate succeds if S is the list od Starts and D is the last of Durations of all occurence of edge(X,Y) in the 
% plan Plan(5th parameter) with allowing usage of edges in range of L..R (1..2 or 1..1)
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
    
    
%it calls collectOne on every single Plan in the Plans list and accumulates the Starts and Durations in the Start,Duration variables
collect(_,_,_,_,[],[],[]).
collect(X,Y,L,R,[H|T],Start,Duration):-
    collectOne(X,Y,L,R,H,S1,D1),
    collect(X,Y,L,R,T,S2,D2),
    append(S1,S2,Start),
    append(D1,D2,Duration).

% generate10(A,B) generates a list of 10s B with the same length of list A
generate10([],[]).
generate10([_|T],[10|T2]):-
    generate10(T,T2).

% this prefdicate succeds if all occurences of edge(x,y) are valid [according the security constraint, there should be at
% least 10 mins between each train of the trains]
validate(X,Y,Plan):-
    collect(X,Y,1,2,Plan,Start, _),
    generate10(Start,Duration),
    serialized(Start, Duration).
% validateAll(A,B,Plan) this predicate calls validate predicate on each edge in (A,B) lists to validate it inside the plan
% this predicate takes care of the constraint that for each edge, its trains should be seperaterd by at least 10 mins
validateAll([],[],_).
validateAll([H1|T1],[H2|T2],Plan):-
    validate(H1,H2,Plan),
    validateAll(T1,T2,Plan).

% this predicate succeeds if R is minimum number between A and B
min(A,B,R):-
    A#<B #<==> AGB,
    B#=<A #<==> BGA,
    R#= AGB*A + BGA*B.
    
%this predicate checks the constraint of (no two trains pass through the same edge at the same time) for a single train represented by 
% Start X and duration D1 against all the variables in the two lists Start2, Duration2
validate4(_,[],_,_).
validate4(X,[H|T],D1,[H1|T1]):-
    % S=[X,H],
    % D=[D1,H1],
    % serialized(S,D),
    min(D1,H1,Min),
    abs(H-X)#>=Min,
    validate4(X,T,D1,T1).

%this predicate succeeds if the list of trains represented by Start1, Duration1 and list of trains represented by Start2, Duration2
% are mutually exclusive (such that no two trains pass through the same edge at the same time)
validate3([],_,_,_).
validate3([H|T],Start2,[H1|T1],D2):-
    validate4(H,Start2,H1,D2),
    validate3(T,Start2,T1,D2).
%this predicate succeeds if Start1 and D1 are lists of Starts and durations in  the Plan where the edge(X,Y) is used inside it
% and the mutual exclusion between all these variables is validated through the validate3 predicate
% it collects al variables Start1, Duration1 for the trains passing through edge X->Y
% it collects al variables Start2, Duration2 for the trains passing through edge Y->X

validate2(X,Y,E,Plan):-
    collect(X,Y,E,E,Plan,Start1,D1),
    collect(Y,X,E,E,Plan,Start2,D2),
    validate3(Start1,Start2,D1,D2).

%this predicate call validate2 for each corresponding pair of numbers  in the two lists L1,L2 one time using edges with label 1
% and another time with edges of label2
validateAll2([],[],_).
validateAll2([H1|T1],[H2|T2],Plan):-
    validate2(H1,H2,1,Plan),
    validate2(H1,H2,2,Plan),
    validateAll2(T1,T2,Plan).

%generate(X,Y,R1,R2) this methods succeds if R1,R2 Lists are consisting of every pairs of nodes starting from (X,Y) 
% till (maxNodes,maxNodes)
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

% this is the predicate that solves the problem it takes List of trains represented by two lists S1(from), S2 (to), Release (the Release
% time for each train) and Due(the time where the plan arrives) and generates a valid plan Plan with the minimum total delay (TotalDelay)
solveProblem(S1,S2,Release,Due,Plan,TotalDelay):-
    solveAll(S1,S2,Release,Due,Plan,TotalDelay),
    generate(1,1,L1,L2),
    validateAll(L1,L2,Plan),
    validateAll2(L1,L2,Plan),
    flatten(Plan,X),
    labeling([min(TotalDelay)],X).

% maxNodes(3).
% mat(X):- X =  [ [ 0, 10, 1000 ], [ 10, 0, 20 ], [ 1000, 20, 0 ] ].
% cntMat(X):- X =  [ [ 0, 1, 1000 ], [ 1, 0, 1 ], [ 1000, 1, 0 ] ].
