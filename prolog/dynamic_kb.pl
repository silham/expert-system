% =============================================================================
% dynamic_kb.pl  --  ExoHabitability Advisor : Dynamic Knowledge Base (Phase 9)
% =============================================================================
%
% Lets the user grow or shrink the knowledge base AT RUNTIME with assertz/1 and
% retract/1 (retractall/1). Because all fact predicates were declared
% `:- dynamic` in facts.pl, the engine immediately reasons over newly added
% planets -- classification/explanation work on them with no reload.
%
% Concept demonstrated: dynamic database manipulation (assert / retract).
%
% Depends on: facts.pl (dynamic declarations), and the reasoning modules for
% the demonstrate/0 predicate.
% =============================================================================

% -----------------------------------------------------------------------------
% add_planet(+Name)
%   Minimal form (matches the AGENTS.md example): register a bare planet.
%   Refuses to add a duplicate.
% -----------------------------------------------------------------------------
add_planet(Name) :-
    ( planet(Name)
    -> format('Planet ~w already exists.~n', [Name])
    ;  assertz(planet(Name)),
       format('Added planet ~w.~n', [Name]) ).

% -----------------------------------------------------------------------------
% add_planet(+Name, +StarType, +Radius, +Mass, +Temp, +InZone, +HasWater,
%            +Atmosphere, +Radiation)
%   Full form: assert a complete planet with all attributes in one call.
%     InZone, HasWater : the atoms yes / no (control the 1-arg flag facts).
%   All assertions use assertz/1 so they append after existing clauses.
% -----------------------------------------------------------------------------
add_planet(Name, StarType, Radius, Mass, Temp, InZone, HasWater, Atmosphere, Radiation) :-
    ( planet(Name)
    -> format('Planet ~w already exists -- remove it first.~n', [Name])
    ;  assertz(planet(Name)),
       assertz(star_type(Name, StarType)),
       assertz(radius(Name, Radius)),
       assertz(mass(Name, Mass)),
       assertz(temperature(Name, Temp)),
       ( InZone   == yes -> assertz(in_habitable_zone(Name)) ; true ),
       ( HasWater == yes -> assertz(has_water_indicator(Name)) ; true ),
       assertz(atmosphere(Name, Atmosphere)),
       assertz(radiation_level(Name, Radiation)),
       format('Added planet ~w with full attributes.~n', [Name]) ).

% -----------------------------------------------------------------------------
% remove_planet(+Name)
%   Retract a planet and ALL facts referring to it (retractall/1 never fails,
%   so removing absent facts is safe).
% -----------------------------------------------------------------------------
remove_planet(Name) :-
    ( planet(Name)
    -> retractall(planet(Name)),
       retractall(star_type(Name, _)),
       retractall(radius(Name, _)),
       retractall(mass(Name, _)),
       retractall(temperature(Name, _)),
       retractall(in_habitable_zone(Name)),
       retractall(has_water_indicator(Name)),
       retractall(atmosphere(Name, _)),
       retractall(radiation_level(Name, _)),
       format('Removed planet ~w and all its facts.~n', [Name])
    ;  format('No such planet: ~w~n', [Name]) ).

% -----------------------------------------------------------------------------
% update_temperature(+Name, +NewTemp)
%   Example of an in-place update: retract the old fact, assert the new one.
% -----------------------------------------------------------------------------
update_temperature(Name, NewTemp) :-
    ( planet(Name)
    -> retract(temperature(Name, _)),
       assertz(temperature(Name, NewTemp)),
       format('~w temperature updated to ~w K.~n', [Name, NewTemp])
    ;  format('No such planet: ~w~n', [Name]) ).

% -----------------------------------------------------------------------------
% demonstrate_dynamic
%   Adds a brand-new planet, classifies it, mutates a fact to change the
%   verdict, then removes it -- all at runtime.
% -----------------------------------------------------------------------------
demonstrate_dynamic :-
    format('~n=== Dynamic KB demonstration ===~n~n'),

    format('1) Add a new world "new_eden" with full attributes:~n   '),
    add_planet(new_eden, k_type, 1.1, 1.3, 270, yes, yes, likely, low),

    format('2) Classify it immediately (no reload):~n   '),
    classification(new_eden, C1), class_label(C1, L1),
    format('new_eden => ~w~n', [L1]),

    format('3) Mutate it: push temperature to 500 K (too hot):~n   '),
    update_temperature(new_eden, 500),

    format('4) Re-classify -- the verdict changes:~n   '),
    classification(new_eden, C2), class_label(C2, L2),
    format('new_eden => ~w~n', [L2]),

    format('5) Remove it again:~n   '),
    remove_planet(new_eden),

    format('6) Confirm it is gone: planet(new_eden) is '),
    ( planet(new_eden) -> format('still present (BUG)~n') ; format('false -- correct~n') ).

% =============================================================================
% End of dynamic_kb.pl
% =============================================================================
