% =============================================================================
% planning.pl  --  ExoHabitability Advisor : State-Space Exploration (Phase 12)
% =============================================================================
%
% A classical-AI-planning flavour on top of the expert system. Each planet is
% taken through a survey pipeline of discrete STATES by applying ACTIONS, and a
% recursive planner searches the state space for a path to a goal state.
%
%   state(Planet, Status)        a node in the search space
%   move(State1, Action, State2) a labelled transition (an operator)
%   explore(State)               recursively drive a planet to 'classified'
%   plan(Start, Goal, Plan)      recursive search returning the action sequence
%
% Survey pipeline (the status progression):
%
%   discovered --scan--> scanned --analyze--> analyzed --classify--> classified
%
% Concepts demonstrated: state-space representation, operators/transitions,
% recursive search with a visited-set, plan (action-sequence) construction,
% and integration with the knowledge base (the 'classify' action attaches the
% planet's habitability classification to the final state).
%
% Depends on: facts.pl, rules.pl, classifications.pl
% =============================================================================

% -----------------------------------------------------------------------------
% move(+State1, ?Action, -State2)   -- the transition operators.
%   Each rule fires only when its source status matches, producing the next
%   status. 'classify' consults the expert system to label the planet.
% -----------------------------------------------------------------------------
move(state(P, discovered), scan,    state(P, scanned)) :-
    planet(P).

move(state(P, scanned),    analyze, state(P, analyzed)) :-
    planet(P).

move(state(P, analyzed),   classify, state(P, classified(Class))) :-
    planet(P),
    classification(P, Class).        % <-- expert system invoked here

% -----------------------------------------------------------------------------
% goal_state(+State)  -- recognises a terminal (fully classified) state.
% -----------------------------------------------------------------------------
goal_state(state(_, classified(_))).

% -----------------------------------------------------------------------------
% explore(+State)
%   Recursively apply moves from State until a goal state is reached, printing
%   each transition. This is the recursive planner the brief asks for.
% -----------------------------------------------------------------------------
explore(State) :-
    goal_state(State),
    !,
    State = state(P, classified(Class)),
    format('  reached goal: ~w is fully ~w~n', [P, classified(Class)]),
    format('  => classification: ~w~n', [Class]).
explore(State) :-
    move(State, Action, Next),
    State = state(P, S0),
    Next  = state(_, S1),
    format('  ~w: ~w --[~w]--> ~w~n', [P, S0, Action, S1]),
    explore(Next).                   % RECURSE on the successor state

% -----------------------------------------------------------------------------
% plan(+Start, +Goal, -Plan)
%   Recursive state-space SEARCH returning Plan, the list of actions that leads
%   from Start to Goal. A visited-set of states prevents looping.
% -----------------------------------------------------------------------------
plan(Start, Goal, Plan) :-
    plan(Start, Goal, [Start], Plan).

% plan(+Current, +Goal, +Visited, -Actions)
plan(Goal, Goal, _, []).             % BASE CASE: already at the goal
plan(Current, Goal, Visited, [Action|Rest]) :-   % RECURSIVE CASE
    move(Current, Action, Next),
    \+ member(Next, Visited),
    plan(Next, Goal, [Next|Visited], Rest).

% -----------------------------------------------------------------------------
% survey(+Planet)
%   Convenience: explore a planet starting from 'discovered'.
% -----------------------------------------------------------------------------
survey(Planet) :-
    ( planet(Planet)
    -> format('~n=== Survey pipeline for ~w ===~n', [Planet]),
       explore(state(Planet, discovered))
    ;  format('Unknown planet: ~w~n', [Planet]) ).

% -----------------------------------------------------------------------------
% survey_plan(+Planet, -Plan)
%   The action sequence that takes Planet from 'discovered' to a classified
%   state (the goal class is derived from the expert system first).
% -----------------------------------------------------------------------------
survey_plan(Planet, Plan) :-
    classification(Planet, Class),
    plan(state(Planet, discovered), state(Planet, classified(Class)), Plan).

% =============================================================================
% End of planning.pl
% =============================================================================
