% =============================================================================
% rules.pl  --  ExoHabitability Advisor : Expert Reasoning Rules (Phase 3)
% =============================================================================
%
% This module contains the INFERENCE RULES (Horn clauses) that derive new
% conclusions from the ground facts in facts.pl. It defines no facts of its
% own -- it only reasons over them.
%
% Reasoning concepts demonstrated here:
%   * Horn clauses / rules (Head :- Body)
%   * Predicate logic with arithmetic comparison (>=, =<)
%   * Conjunction of subgoals (the comma = logical AND)
%   * Multiple clauses for one predicate (disjunction = logical OR), e.g.
%     low_radiation/1 succeeds for BOTH 'low' and 'moderate'.
%   * Deductive chaining: habitable/1 is proven only if every subgoal is proven.
%
% Depends on: facts.pl  (loaded together via main.pl in Phase 10).
% =============================================================================

% -----------------------------------------------------------------------------
% earth_like_size(P)
%   True when planet P has a radius in the rocky / Earth-like band.
%   Below ~0.5 R(Earth) a world struggles to hold an atmosphere; above
%   ~1.8 R(Earth) it is likely a gas/ice "mini-Neptune" rather than terrestrial.
% -----------------------------------------------------------------------------
earth_like_size(P) :-
    radius(P, R),
    R >= 0.5,
    R =< 1.8.

% -----------------------------------------------------------------------------
% safe_temperature(P)
%   True when Ps temperature can plausibly support liquid water somewhere on
%   the surface (180 K -- 320 K is our conservative working band).
% -----------------------------------------------------------------------------
safe_temperature(P) :-
    temperature(P, T),
    T >= 180,
    T =< 320.

% -----------------------------------------------------------------------------
% low_radiation(P)
%   Acceptable surface-radiation environment for life.
%   Two clauses => logical OR: 'low' OR 'moderate' both qualify, while 'high'
%   matches neither clause and therefore fails (used by flare-star worlds).
% -----------------------------------------------------------------------------
low_radiation(P) :-
    radiation_level(P, low).
low_radiation(P) :-
    radiation_level(P, moderate).

% -----------------------------------------------------------------------------
% habitable(P)   -- THE MAIN EXPERT RULE
%   P is judged habitable only if ALL of these hold (conjunction):
%     1. it lies in the habitable zone,
%     2. it is Earth-like in size,
%     3. its temperature is in the safe band,
%     4. there is a water indicator,
%     5. it likely has an atmosphere, and
%     6. radiation is not high.
%   If any single subgoal fails, the whole proof fails (and Prolog backtracks).
% -----------------------------------------------------------------------------
habitable(P) :-
    in_habitable_zone(P),
    earth_like_size(P),
    safe_temperature(P),
    has_water_indicator(P),
    atmosphere(P, likely),
    low_radiation(P).

% =============================================================================
% End of rules.pl
% =============================================================================
