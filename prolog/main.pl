% =============================================================================
% main.pl  --  ExoHabitability Advisor : Top-level Loader (Phase 10)
% =============================================================================
%
% Loads every module of the expert system in dependency order so the whole
% system can be started with a single command:
%
%     swipl prolog/main.pl
%
% Relative file references are resolved by SWI-Prolog against THIS file's
% directory, so it works regardless of the current working directory.
%
% Once loaded, useful entry points:
%     consultation.            -- interactive expert consultation (Phase 10)
%     explain(Planet).         -- full reasoning report for one planet
%     classification(P, C).    -- classify a planet
%     candidate_planets(L).    -- list habitability candidates
%     demonstrate_negation.    -- negation-as-failure demo (Phase 8)
%     demonstrate_dynamic.     -- runtime add/update/remove demo (Phase 9)
%     explore(state(P, discovered)).  -- state-space planner demo (Phase 12)
%     help.                    -- reprint this menu
% =============================================================================

% --- Knowledge base -------------------------------------------------------
:- ensure_loaded('facts.pl').          % Phase 2 : planet facts (dynamic)

% --- Reasoning engine -----------------------------------------------------
:- ensure_loaded('rules.pl').          % Phase 3 : habitable/1 + sub-rules
:- ensure_loaded('classifications.pl').% Phase 4 : classification/2 (cut)
:- ensure_loaded('explanations.pl').   % Phase 5 : reason/2, explain/1

% --- Demonstrations of core concepts --------------------------------------
:- ensure_loaded('lists.pl').          % Phase 6 : list processing
:- ensure_loaded('recursion.pl').      % Phase 7 : recursive search
:- ensure_loaded('negation.pl').       % Phase 8 : negation as failure
:- ensure_loaded('dynamic_kb.pl').     % Phase 9 : dynamic database

% --- Interaction & advanced features --------------------------------------
:- ensure_loaded('consultation.pl').   % Phase 10 : interactive consultation
% Phase 12 planner is optional until that phase is built; load it only if present.
:- ( prolog_load_context(directory, Dir),
     absolute_file_name('planning.pl', F, [relative_to(Dir)]),
     exists_file(F)
   -> ensure_loaded('planning.pl')
   ;  true ).

% -----------------------------------------------------------------------------
% help/0  -- print the menu of entry points.
% -----------------------------------------------------------------------------
help :-
    nl,
    write('================================================'), nl,
    write('  ExoHabitability Advisor  -- commands'), nl,
    write('================================================'), nl,
    write('  consultation.             Interactive consultation'), nl,
    write('  explain(Planet).          Full reasoning report'), nl,
    write('  classification(P, C).     Classify a planet'), nl,
    write('  candidate_planets(L).     List candidates'), nl,
    write('  explain_all.              Report every planet'), nl,
    write('  demonstrate_negation.     Negation-as-failure demo'), nl,
    write('  demonstrate_dynamic.      Dynamic KB demo'), nl,
    write('  explore(state(earth, discovered)).  Planner demo'), nl,
    write('  help.                     Show this menu'), nl,
    write('================================================'), nl.

% -----------------------------------------------------------------------------
% Print a short banner once loading is complete.
% -----------------------------------------------------------------------------
:- initialization(
     ( nl,
       write('ExoHabitability Advisor loaded. Type  help.  for commands,'), nl,
       write('or  consultation.  to start an interactive session.'), nl )
   ).

% =============================================================================
% End of main.pl
% =============================================================================
