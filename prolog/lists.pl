% =============================================================================
% lists.pl  --  ExoHabitability Advisor : List Processing (Phase 6)
% =============================================================================
%
% Demonstrates Prolog list handling over the knowledge base, using the three
% library predicates the course emphasises:
%
%     member/2   -- membership test / generation
%     append/3   -- list concatenation
%     length/2   -- list length
%
% Plus findall/3 to gather solutions into a list. Depends on facts.pl,
% rules.pl, classifications.pl.
% =============================================================================

% -----------------------------------------------------------------------------
% potentially_habitable(+P)
%   True if P's class is one of the "worth investigating" categories.
%   Uses member/2 to test the class against a list of acceptable categories.
% -----------------------------------------------------------------------------
potentially_habitable(P) :-
    planet(P),                         % bind P first: classify/2 commits via cut,
    classification(P, Class),          % so it must be called with P already bound.
    member(Class, [habitable, possible_habitable]).

% -----------------------------------------------------------------------------
% candidate_planets(-List)
%   THE Phase-6 predicate: all potentially-habitable planets, gathered with
%   findall/3.
% -----------------------------------------------------------------------------
candidate_planets(List) :-
    findall(P, potentially_habitable(P), List).

% -----------------------------------------------------------------------------
% habitable_planets(-List) / possible_planets(-List)
%   The two sub-lists that make up the candidates.
% -----------------------------------------------------------------------------
habitable_planets(List) :-
    findall(P, ( planet(P), classification(P, habitable) ), List).

possible_planets(List) :-
    findall(P, ( planet(P), classification(P, possible_habitable) ), List).

% -----------------------------------------------------------------------------
% candidate_planets_appended(-List)
%   Same set as candidate_planets/1, but built by CONCATENATING the two
%   sub-lists with append/3 -- shows list construction rather than collection.
% -----------------------------------------------------------------------------
candidate_planets_appended(List) :-
    habitable_planets(H),
    possible_planets(Po),
    append(H, Po, List).               % append/3

% -----------------------------------------------------------------------------
% candidate_count(-N)
%   How many candidate planets there are, via length/2.
% -----------------------------------------------------------------------------
candidate_count(N) :-
    candidate_planets(List),
    length(List, N).                   % length/2

% -----------------------------------------------------------------------------
% is_candidate(+P)
%   Membership query: is P in the candidate list?  Uses member/2.
% -----------------------------------------------------------------------------
is_candidate(P) :-
    candidate_planets(List),
    member(P, List).                   % member/2

% -----------------------------------------------------------------------------
% planets_by_class(+Class, -List)
%   Generic: every planet of a given classification.
% -----------------------------------------------------------------------------
planets_by_class(Class, List) :-
    findall(P, ( planet(P), classification(P, Class) ), List).

% =============================================================================
% End of lists.pl
% =============================================================================
