% =============================================================================
% recursion.pl  --  ExoHabitability Advisor : Recursive Reasoning (Phase 7)
% =============================================================================
%
% Demonstrates RECURSION two ways:
%
%   (A) Graph recursion over an interstellar "jump network": reachability and
%       path-finding with a visited-set to guarantee termination on cycles.
%   (B) Classic structural recursion over a list (base case + recursive case)
%       to count how many planets satisfy a condition.
%
% Depends on: facts.pl, rules.pl, classifications.pl, lists.pl
% =============================================================================

% -----------------------------------------------------------------------------
% jump(+From, +To)   -- directed star-hop a survey ship can make.
%   These facts define a small graph over the known planets.
% -----------------------------------------------------------------------------
jump(earth,              mars).
jump(mars,               proxima_centauri_b).
jump(proxima_centauri_b, trappist_1e).
jump(trappist_1e,        trappist_1d).
jump(earth,              luyten_b).
jump(luyten_b,           teegarden_b).
jump(teegarden_b,        gliese_667cc).
jump(gliese_667cc,       kepler_442b).
jump(kepler_442b,        kepler_452b).
jump(kepler_452b,        kepler_22b).
jump(kepler_22b,         venus).

% -----------------------------------------------------------------------------
% edge(?A, ?B)  -- jumps are traversable in BOTH directions.
% -----------------------------------------------------------------------------
edge(A, B) :- jump(A, B).
edge(A, B) :- jump(B, A).

% -----------------------------------------------------------------------------
% reachable(+Start, ?Dest)   -- RECURSIVE reachability.
%   Dest is reachable from Start by following one or more edges, without
%   revisiting a node (the Visited list is what makes recursion terminate).
% -----------------------------------------------------------------------------
reachable(Start, Dest) :-
    reachable(Start, Dest, [Start]).

% reachable(+Current, ?Dest, +Visited)
reachable(Current, Dest, Visited) :-          % BASE-ish: one hop to a new node
    edge(Current, Dest),
    \+ member(Dest, Visited).
reachable(Current, Dest, Visited) :-          % RECURSIVE: hop then continue
    edge(Current, Next),
    \+ member(Next, Visited),
    reachable(Next, Dest, [Next|Visited]).

% -----------------------------------------------------------------------------
% planet_path(+Start, +Goal, -Path)   -- RECURSIVE path construction.
%   Path is the list of planets visited travelling from Start to Goal.
% -----------------------------------------------------------------------------
planet_path(Start, Goal, Path) :-
    travel(Start, Goal, [Start], RevPath),
    reverse(RevPath, Path).

% travel(+Current, +Goal, +VisitedAcc, -VisitedFull)
travel(Goal, Goal, Visited, Visited).         % BASE CASE: arrived at the goal
travel(Current, Goal, Visited, Path) :-       % RECURSIVE CASE: step to a neighbour
    edge(Current, Next),
    \+ member(Next, Visited),
    travel(Next, Goal, [Next|Visited], Path).

% -----------------------------------------------------------------------------
% reachable_candidate(+Start, -Dest)
%   A habitability candidate (Phase 6) that can be reached from Start.
% -----------------------------------------------------------------------------
reachable_candidate(Start, Dest) :-
    reachable(Start, Dest),
    is_candidate(Dest).

% -----------------------------------------------------------------------------
% (B) Classic structural list recursion.
% count_candidates_in(+Planets, -Count)
%   Count how many planets in the given list are habitability candidates.
%     base case : empty list -> 0
%     recursive : head counts as 1 (or 0) plus the count of the tail
% -----------------------------------------------------------------------------
count_candidates_in([], 0).
count_candidates_in([P|Ps], Count) :-
    count_candidates_in(Ps, Rest),
    ( is_candidate(P)
    -> Count is Rest + 1
    ;  Count is Rest ).

% =============================================================================
% End of recursion.pl
% =============================================================================
