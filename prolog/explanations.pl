% =============================================================================
% explanations.pl  --  ExoHabitability Advisor : Explanation System (Phase 5)
% =============================================================================
%
% Turns the system from a black box into a GLASS box: for any planet it lists
% the individual observations that support (reason/2) or count against
% (concern/2) habitability, then prints a tidy report with explain/1.
%
% Each reason/2 and concern/2 clause is itself a small rule whose body is one
% of the habitability conditions -- so the "explanation" is literally produced
% by re-running the reasoning, not by a hand-written summary. Backtracking over
% these clauses enumerates every applicable line.
%
% Depends on: facts.pl, rules.pl, classifications.pl
% =============================================================================

% -----------------------------------------------------------------------------
% reason(+Planet, -Text)
%   Succeeds once per POSITIVE habitability factor that holds for Planet.
%   (Multiple clauses => backtracking yields all applicable reasons.)
% -----------------------------------------------------------------------------
reason(P, 'Located in habitable zone') :-
    in_habitable_zone(P).
reason(P, 'Earth-like size (rocky world)') :-
    earth_like_size(P).
reason(P, 'Temperature suitable for liquid water') :-
    safe_temperature(P).
reason(P, 'Water indicators detected') :-
    has_water_indicator(P).
reason(P, 'Atmosphere likely present') :-
    atmosphere(P, likely).
reason(P, 'Acceptable radiation environment') :-
    low_radiation(P).

% -----------------------------------------------------------------------------
% concern(+Planet, -Text)
%   Succeeds once per NEGATIVE factor (a reason the planet may NOT be habitable).
%   Uses negation-as-failure (\+) to detect missing/failing conditions -- a
%   light preview of Phase 8.
% -----------------------------------------------------------------------------
concern(P, 'Outside the habitable zone') :-
    \+ in_habitable_zone(P).
concern(P, 'Size unlike Earth (not a rocky world)') :-
    \+ earth_like_size(P).
concern(P, 'Temperature outside the liquid-water band') :-
    \+ safe_temperature(P).
concern(P, 'No water indicators') :-
    \+ has_water_indicator(P).
concern(P, 'Atmosphere thin / absent / unsuitable') :-
    \+ atmosphere(P, likely).
concern(P, 'High radiation environment') :-
    \+ low_radiation(P).

% -----------------------------------------------------------------------------
% explain(+Planet)
%   Pretty-prints a full reasoning report:
%     header, supporting reasons, concerns, and the final classification.
% -----------------------------------------------------------------------------
explain(Planet) :-
    ( planet(Planet)
    -> print_report(Planet)
    ;  format('Unknown planet: ~w~n', [Planet]) ).

print_report(Planet) :-
    format('~n========================================~n'),
    format('Planet: ~w~n', [Planet]),
    format('========================================~n'),

    % --- supporting reasons ---
    format('Supporting factors:~n'),
    ( reason(Planet, _)
    -> forall(reason(Planet, R), format('  + ~w~n', [R]))
    ;  format('  (none)~n') ),

    % --- concerns ---
    format('Concerns:~n'),
    ( concern(Planet, _)
    -> forall(concern(Planet, C), format('  - ~w~n', [C]))
    ;  format('  (none)~n') ),

    % --- final classification ---
    classification(Planet, Class),
    class_label(Class, Label),
    format('----------------------------------------~n'),
    format('Classification: ~w~n', [Label]),
    format('========================================~n').

% -----------------------------------------------------------------------------
% explain_all
%   Convenience: print a report for every known planet.
% -----------------------------------------------------------------------------
explain_all :-
    forall(planet(P), explain(P)).

% =============================================================================
% End of explanations.pl
% =============================================================================
