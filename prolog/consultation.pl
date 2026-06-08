% =============================================================================
% consultation.pl  --  ExoHabitability Advisor : Interactive Consultation (Ph.10)
% =============================================================================
%
% A simple read-eval-print expert consultation loop built from the classic
% Prolog I/O primitives: read/1, write/1, nl/0 (plus format/2 for layout).
%
% The user types a planet name FOLLOWED BY A FULL STOP (read/1 reads a Prolog
% term), e.g.:   kepler_442b.
% Typing  quit.  ends the session.
%
% Depends on: facts.pl, rules.pl, classifications.pl, explanations.pl
% =============================================================================

% -----------------------------------------------------------------------------
% consultation/0  -- entry point for the interactive session.
% -----------------------------------------------------------------------------
consultation :-
    nl,
    write('=========================================='), nl,
    write('   ExoHabitability Advisor -- Consultation'), nl,
    write('=========================================='), nl,
    write('Type a planet name followed by a period, e.g.  earth.'), nl,
    write('Type  list.   to see all known planets.'), nl,
    write('Type  quit.   to exit.'), nl,
    consult_loop.

% -----------------------------------------------------------------------------
% consult_loop/0  -- recursive prompt/read/respond cycle.
% -----------------------------------------------------------------------------
consult_loop :-
    nl,
    write('Enter Planet Name:'), nl,
    write('> '),
    read(Input),                       % read/1 : reads one term ended by '.'
    handle(Input).

% handle(+Input)
handle(quit) :-
    !,
    nl, write('Ending consultation. Goodbye.'), nl.
handle(list) :-
    !,
    nl, write('Known planets:'), nl,
    forall(planet(P), (write('  - '), write(P), nl)),
    consult_loop.                      % loop again
handle(Planet) :-
    respond(Planet),
    consult_loop.                      % loop again

% -----------------------------------------------------------------------------
% respond(+Planet)  -- classify + explain a single planet, or report unknown.
% -----------------------------------------------------------------------------
respond(Planet) :-
    ( planet(Planet)
    -> classification(Planet, Class),
       class_label(Class, Label),
       nl,
       write('Classification: '), write(Label), nl,
       write('Reasons:'), nl,
       forall(reason(Planet, R), (write('  - '), write(R), nl)),
       ( concern(Planet, _)
       -> write('Concerns:'), nl,
          forall(concern(Planet, C), (write('  - '), write(C), nl))
       ;  true )
    ;  nl, write('Unknown planet: '), write(Planet), nl,
       write('(type  list.  to see known planets)'), nl ).

% =============================================================================
% End of consultation.pl
% =============================================================================
