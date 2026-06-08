# AGENTS.md

# Project: ExoHabitability Advisor

## Overview

This project is an AI Expert System built using Prolog to evaluate the habitability of extraterrestrial planets.

The primary objective is to demonstrate concepts taught in the Deductive Reasoning and Logic Programming module, including:

- Predicate Logic
- Facts and Rules
- Horn Clauses
- Deductive Reasoning
- Query Processing
- Backtracking
- Recursion
- Lists
- Cut (`!`)
- Negation as Failure
- Dynamic Knowledge Bases
- Expert Systems

The final application should consist of:

- A SWI-Prolog knowledge base and inference engine
- A Python GUI (preferred) or Web UI
- An explanation system showing reasoning steps
- Sample exoplanet datasets
- Demonstration queries

---

# IMPORTANT DEVELOPMENT RULES

## Rule 1

DO NOT start implementing the expert system immediately.

First verify that the development environment is fully configured.

Implementation must follow the phases defined in this document.

## Rule 2

At the end of every phase provide:

- What was completed
- Files created
- Files modified
- How to test

Then wait for approval before moving to the next phase.

## Rule 3

Keep Prolog code modular.

Avoid placing everything in a single `.pl` file.

---

# Phase 1 — Setup SWI-Prolog Environment

## Goal

Create a working Prolog environment.

### Tasks

Detect operating system.

If macOS:

```bash
brew install swi-prolog
```

Verify installation:

```bash
swipl
```

Expected output:

```text
Welcome to SWI-Prolog
```

Create project structure:

```text
exo-habitability-advisor/

├── prolog/
│   ├── facts.pl
│   ├── rules.pl
│   ├── classifications.pl
│   ├── explanations.pl
│   └── main.pl
│
├── python/
│   ├── app.py
│   └── requirements.txt
│
├── docs/
│
└── README.md
```

Create a simple test file:

```prolog
planet(earth).

is_habitable(earth).
```

Verify:

```prolog
?- is_habitable(earth).
```

returns:

```text
true.
```

Do not continue until Phase 1 is verified.

---

# Phase 2 — Build Planet Knowledge Base

## Goal

Create the factual knowledge base.

Represent planets using facts.

Example:

```prolog
planet(kepler_442b).

star_type(kepler_442b, k_type).

radius(kepler_442b, 1.34).

mass(kepler_442b, 2.3).

temperature(kepler_442b, 265).

in_habitable_zone(kepler_442b).

has_water_indicator(kepler_442b).

atmosphere(kepler_442b, likely).

radiation_level(kepler_442b, moderate).
```

Include at least:

- Earth
- Mars
- Proxima Centauri b
- Kepler-442b
- TRAPPIST-1e
- Kepler-452b

Minimum dataset size:

10 planets.

---

# Phase 3 — Expert Rules

## Goal

Create expert reasoning rules.

Examples:

```prolog
earth_like_size(P) :-
    radius(P, R),
    R >= 0.5,
    R =< 1.8.
```

```prolog
safe_temperature(P) :-
    temperature(P, T),
    T >= 180,
    T =< 320.
```

```prolog
low_radiation(P) :-
    radiation_level(P, low).
```

```prolog
low_radiation(P) :-
    radiation_level(P, moderate).
```

Main rule:

```prolog
habitable(P) :-
    in_habitable_zone(P),
    earth_like_size(P),
    safe_temperature(P),
    has_water_indicator(P),
    atmosphere(P, likely),
    low_radiation(P).
```

The system must infer conclusions from facts.

---

# Phase 4 — Classification Engine

Classify planets into:

```text
Habitable
Possibly Habitable
Terraforming Candidate
Uninhabitable
```

Example:

```prolog
classification(P, habitable) :-
    habitable(P), !.
```

```prolog
classification(P, possible_habitable) :-
    in_habitable_zone(P),
    safe_temperature(P), !.
```

```prolog
classification(P, terraforming_candidate) :-
    atmosphere(P, none), !.
```

```prolog
classification(_, uninhabitable).
```

Use cut (`!`) where appropriate.

---

# Phase 5 — Explanation System

Provide reasoning.

Example:

```prolog
reason(P, 'Located in habitable zone') :-
    in_habitable_zone(P).
```

```prolog
reason(P, 'Temperature suitable for liquid water') :-
    safe_temperature(P).
```

Create:

```prolog
explain(Planet).
```

Output example:

```text
Planet: Kepler-442b

Reason:
- Located in habitable zone
- Suitable temperature
- Possible atmosphere
- Water indicators detected

Classification:
Habitable
```

---

# Phase 6 — Demonstrate Lists

The course heavily emphasizes list processing.

Implement:

```prolog
candidate_planets(List).
```

Returns all potentially habitable planets.

Use:

- member/2
- append/3
- length/2

where appropriate.

---

# Phase 7 — Demonstrate Recursion

Create recursive search predicates.

Examples:

```prolog
reachable_candidate(X).
```

or

```prolog
planet_path(Start, Goal, Path).
```

Purpose:

Demonstrate recursive Prolog reasoning.

---

# Phase 8 — Demonstrate Negation

Use negation as failure.

Example:

```prolog
not_habitable(P) :-
    \+ habitable(P).
```

Demonstrate at least three cases.

---

# Phase 9 — Dynamic Knowledge Base

Allow user-added planets.

Example:

```prolog
:- dynamic planet/1.
```

```prolog
add_planet(Name).
```

using:

```prolog
assertz(...)
```

Remove:

```prolog
retract(...)
```

Demonstrate runtime updates.

---

# Phase 10 — Interactive Expert Consultation

Create:

```prolog
consultation.
```

Flow:

```text
Enter Planet Name:
> Kepler_442b

Classification:
Habitable

Reasons:
...
```

Use:

```prolog
read/1.
write/1.
nl.
```

---

# Phase 11 — Python GUI

Preferred technology:

- Python
- Streamlit
- PySwip

Install:

```bash
pip install streamlit pyswip
```

Features:

- Select planet
- View facts
- Run classification
- View explanation
- Add new planets
- Query Prolog

---

# Phase 12 — Advanced Feature (Bonus Marks)

Implement state-space exploration inspired by classical AI planning.

Use:

```prolog
move(State1, Action, State2).
```

Model:

```prolog
state(Planet, Status).
```

Example:

```prolog
move(
    state(P, discovered),
    scan,
    state(P, scanned)
).
```

```prolog
move(
    state(P, scanned),
    analyze,
    state(P, analyzed)
).
```

```prolog
move(
    state(P, analyzed),
    classify,
    state(P, classified)
).
```

Create recursive planner:

```prolog
explore(State).
```

This demonstrates AI problem-solving techniques taught in class.

---

# Success Criteria

The project should clearly demonstrate:

- Facts
- Rules
- Queries
- Deductive Reasoning
- Recursion
- Backtracking
- Lists
- Cut
- Negation
- Dynamic Database Manipulation
- Input/Output
- Expert System Design

The reasoning process should be visible and explainable rather than functioning as a black box.

The final system should be suitable for an academic demonstration in a Logic Programming and AI course.

---

# Presentation Notes

The lecturer strongly emphasizes:

- Goal matching
- Variable substitution
- Derivation trees
- Backtracking
- Recursive reasoning

Therefore the final demonstration must include at least one example showing:

```prolog
?- classification(kepler_442b, X).
```

and explain:

1. Which rule matched
2. Variable substitutions performed
3. Generated subgoals
4. Backtracking behavior
5. Final conclusion

The project should prioritize demonstrating Prolog reasoning over GUI complexity.