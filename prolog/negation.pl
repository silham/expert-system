% =============================================================================
% negation.pl  --  ExoHabitability Advisor : Negation as Failure (Phase 8)
% =============================================================================
%
% Demonstrates NEGATION AS FAILURE using the \+ operator: `\+ Goal` succeeds
% exactly when Prolog CANNOT prove Goal. This is "closed-world" negation --
% anything not provable from the knowledge base is treated as false.
%
% IMPORTANT (mode): \+ does not bind variables, so these predicates are meant
% to be called with the planet already bound (we guard with planet/1 where we
% need to enumerate, so the negated goal is always ground).
%
% Depends on: facts.pl, rules.pl, classifications.pl
% =============================================================================

% -----------------------------------------------------------------------------
% not_habitable(+P)
%   The canonical example: P is not habitable if habitable(P) cannot be proven.
% -----------------------------------------------------------------------------
not_habitable(P) :-
    planet(P),
    \+ habitable(P).

% -----------------------------------------------------------------------------
% no_atmosphere(+P)
%   True when P does NOT have a 'likely' atmosphere (none/thin/thick/unknown).
% -----------------------------------------------------------------------------
no_atmosphere(P) :-
    planet(P),
    \+ atmosphere(P, likely).

% -----------------------------------------------------------------------------
% not_in_zone(+P)
%   True when P is NOT recorded as being in the habitable zone.
% -----------------------------------------------------------------------------
not_in_zone(P) :-
    planet(P),
    \+ in_habitable_zone(P).

% -----------------------------------------------------------------------------
% lacks_water(+P)
%   True when there is NO water indicator for P.
% -----------------------------------------------------------------------------
lacks_water(P) :-
    planet(P),
    \+ has_water_indicator(P).

% -----------------------------------------------------------------------------
% definitely_uninhabitable(+P)
%   Combines two negations: not habitable AND not even a candidate.
% -----------------------------------------------------------------------------
definitely_uninhabitable(P) :-
    not_habitable(P),
    \+ classification(P, possible_habitable).

% -----------------------------------------------------------------------------
% demonstrate_negation
%   Prints at least three explicit negation-as-failure cases (Phase 8 require-
%   ment) with their explanations.
% -----------------------------------------------------------------------------
demonstrate_negation :-
    format('~n=== Negation as Failure: demonstrations ===~n~n'),

    % Case 1: \+ habitable
    format('Case 1  not_habitable(venus):  '),
    ( not_habitable(venus)
    -> format('TRUE  (habitable(venus) cannot be proven)~n')
    ;  format('false~n') ),

    % Case 2: \+ atmosphere(_, likely)
    format('Case 2  no_atmosphere(mars):   '),
    ( no_atmosphere(mars)
    -> format('TRUE  (atmosphere(mars,likely) cannot be proven; it is none)~n')
    ;  format('false~n') ),

    % Case 3: \+ in_habitable_zone
    format('Case 3  not_in_zone(venus):    '),
    ( not_in_zone(venus)
    -> format('TRUE  (in_habitable_zone(venus) cannot be proven)~n')
    ;  format('false~n') ),

    % Case 4 (contrast): a provable goal => its negation FAILS
    format('Case 4  not_habitable(earth):  '),
    ( not_habitable(earth)
    -> format('TRUE~n')
    ;  format('FALSE (habitable(earth) IS provable, so \\+ fails) -- correct~n') ),

    nl,
    format('All planets that are not_habitable:~n  '),
    findall(P, not_habitable(P), NotHab),
    format('~w~n', [NotHab]).

% =============================================================================
% End of negation.pl
% =============================================================================
