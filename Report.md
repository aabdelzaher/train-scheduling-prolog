The model we used is as follows:
For the input : there are four lists in the input 
- S1 : list of the departure cities of the trains
- S2 : list of the arrival cities of the trains
- Release: list of timings each train will be available to be released
- Due : list of timings each train is expected to arrive
- maxNodes: the number of the nodes in the graph

For the Output: a list called Plans is the output
Plans is a list of Plans each Plan is for a train
Each Plan consists of 
- From : list of cities the train will depart from in order
- To : list of cities the train will arrive to in order
- In : a list of timings where the train will leave each of the From cities
- Out : a list of timings where the train will arrive to each of the To cities
- Edges : a list representing we took the first edge or the second edge in the way from node in From to the node in To [if there is a second Edge]

The domains for the From and To are 1..MaxNodes
The domains for the In and Out timings are 1..1440 representing the minutes of the day

Each predicate is documented in the .pl file


|Predicate |Documentation|
|---|---|
| solve(X,Y,Z,Plan)  |  This is a predicate that solves the problem,it succeeds if X:Number of Nodes of the graph, Y: 2D array representing the adjacency matrix of the graph, Z: count Matrix where Z[i,j] is 0 if there is no edge between i and j, 1 if there is 1 edge between i and j and 2 if there are two edges between i and j Plan is a valid plan according to the description in the report |
| adj(X,Y,Val):  | this predicate succeds if the length of the edge between node X and node Y is Val  |
|  cntAdj(X,Y,Val) |  this predicate succeds if the count pod edges between node X and Node Y is Val. It has a value of 0,1 or 2 |
|path(X,Y,Path,Cost,Length)  | this predicate succeeds if the shortest path between node X and node Y is Path, with Cost = C and with length =< Length  |
|remove_duplicates   | this predicate succeeds if the second argument is the path in the first argument but after removing the duplicates (if it takes some self loops)  |
|getPath(X,Y,Ret)   |this predicate gets the path Ret which is the shortest path between the nodes X, Y after removing the duplicates   |
| getPlan(Path,From,To,In,Out,Edge,T1)  | this predicate succeeds if Path is a sequence of nodes, From and To are two lists representing pairs of every consecutive nodes in the path for example if the Path is [1,2,4,5] --> From = [1,2,4] and To = [2,4,5], In is a list of timings the trains will leave every corresponding node in the list From and Out is a list of timings where the train will leave nodes in the list To, and T1 is the time the train has left the last node  |
| solve1(X,Y,From,To,In,Out,Edge,MinTime)  | this predicate succeeds if [From,To,In,Out] is a Plan (which is explained in the report) for the train travelling from node X to node Y and Edge[i] represents which edge is chosen (edge 1 or 2) in the path between From[i] and To[i], and minTime is the time where the train will start its trip after  |
| solveAll  | The predicate solveAll(S1, S2, Release Time, Due Time, Plans , Total Delay) it calls solve1 predicate for each train represented in list S1 and S2 with release time and due time in lists Release Time and Due Time and accumulates a list of Plans for each train in the Plans List and TotalDelay is the summation of delays of the trains from their sue time  |
| collectOne(X,Y,L,R,Plan,S,D)   | This predicate succeds if S is the list od Starts and D is the last of Durations of all occurence of edge(X,Y) in the  plan Plan(5th parameter) with allowing usage of edges in range of L..R (1..2 or 1..1)  |
| collect(X,Y,L,R,Plans,Start,Duration):  | it calls collectOne on every single Plan in the Plans list and accumulates the Starts and Durations in the Start,Duration variables  |
| generate10  | generate10(A,B) generates a list of 10s B with the same length of list A  |
| validate(X,Y,Plan)  | this prefdicate succeds if all occurences of edge(x,y) are valid [according the security constraint, there should be at least 10 mins between each train of the trains]  |
| validateAll  | validateAll(A,B,Plan) this predicate calls validate predicate on each edge in (A,B) lists to validate it inside the plan this predicate takes care of the constraint that for each edge, its trains should be seperaterd by at least 10 mins  |
| min(A,B,R)  | this predicate succeeds if R is minimum number between A and B  |
|validate4(X,Start2,D1,Duration2 )   | this predicate checks the constraint of (no two trains pass through the same edge at the same time) for a single train represented by  Start X and duration D1 against all the variables in the two lists Start2, Duration2  |
|validate3(Start1,Start2,Duration1,D2 )   | this predicate succeeds if the list of trains represented by Start1, Duration1 and list of trains represented by Start2, Duration2 are mutually exclusive (such that no two trains pass through the same edge at the same time)  |
|validate2(X,Y,E,Plan)   | this predicate succeeds if Start1 and D1 are lists of Starts and durations in  the Plan where the edge(X,Y) is used inside it and the mutual exclusion between all these variables is validated through the validate3 predicate it collects al variables Start1, Duration1 for the trains passing through edge X->Y it collects al variables Start2, Duration2 for the trains passing through edge Y->X  |
| validateAll2  | this predicate call validate2 for each corresponding pair of numbers  in the two lists L1,L2 one time using edges with label 1 and another time with edges of label2  |
| generate  |generate(X,Y,R1,R2) this methods succeds if R1,R2 Lists are consisting of every pairs of nodes starting from (X,Y)  till (maxNodes,maxNodes)   |
| solveProblem(S1,S2,Release,Due,Plan,TotalDelay)  |  this is the predicate that solves the problem it takes List of trains represented by two lists S1(from), S2 (to), Release (the Release time for each train) and Due(the time where the plan arrives) and generates a valid plan Plan with the minimum total delay (TotalDelay) |
