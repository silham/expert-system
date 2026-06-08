% =============================================================================
% classifications.pl  --  ExoHabitability Advisor : Classification Engine (Ph.4)
% =============================================================================
%
% Sorts each planet into exactly ONE of four mutually-exclusive categories:
%
%     habitable             -- passes the full habitable/1 expert rule
%     possible_habitable    -- in the zone & temperate, but not fully habitable
%     terraforming_candidate-- airless world that could be engineered
%     uninhabitable         -- none of the above
%
% Concept demonstrated: the CUT (!).
%   The category clauses are tried top-to-bottom. The first one whose body
%   succeeds commits via `!`, so NO later (lower-priority) category can be
%   reached on backtracking. This gives each planet a single, deterministic
%   classification and encodes a priority order:
%       habitable > possible_habitable > terraforming_candidate > uninhabitable
%
% Depends on: facts.pl, rules.pl
% =============================================================================

% -----------------------------------------------------------------------------
% classification(+Planet, ?Class)
%   Public entry point. We deliberately compute the class into a FRESH unbound
%   variable (Derived) and only THEN unify it with the caller's Class.
%
%   Why: the cut-chain in classify/2 only behaves correctly when its 2nd
%   argument is unbound (mode +,-). If a caller asked classification(earth,
%   uninhabitable) directly, head-unification would skip the higher clauses
%   and the catch-all would wrongly succeed. Computing into Derived first, then
%   unifying, keeps the predicate correct in BOTH modes (+,-) and (+,+).
% -----------------------------------------------------------------------------
classification(Planet, Class) :-
    classify(Planet, Derived),
    Class = Derived.

% -----------------------------------------------------------------------------
% classify(+Planet, -Class)   [internal -- always called with Class unbound]
%   The cut-committed priority chain.
% -----------------------------------------------------------------------------
classify(P, habitable) :-
    habitable(P),
    !.                                 % committed: it's fully habitable, stop.

classify(P, possible_habitable) :-
    in_habitable_zone(P),
    safe_temperature(P),
    !.                                 % right neighbourhood & temperature.

classify(P, terraforming_candidate) :-
    atmosphere(P, none),
    !.                                 % airless but potentially engineerable.

classify(_, uninhabitable).            % catch-all: nothing else matched.

% -----------------------------------------------------------------------------
% class_label(+Class, -HumanReadable)
%   Pretty names for display (used by the explanation system / GUI).
% -----------------------------------------------------------------------------
class_label(habitable,              'Habitable').
class_label(possible_habitable,     'Possibly Habitable').
class_label(terraforming_candidate, 'Terraforming Candidate').
class_label(uninhabitable,          'Uninhabitable').

% -----------------------------------------------------------------------------
% classify_all(-Pairs)
%   Convenience: Pairs = [Planet-Class, ...] for every known planet.
% -----------------------------------------------------------------------------
classify_all(Pairs) :-
    findall(P-C, ( planet(P), classification(P, C) ), Pairs).

% =============================================================================
% End of classifications.pl
% =============================================================================
