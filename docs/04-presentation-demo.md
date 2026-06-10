# 5-Minute Academic Presentation Guide

This guide is a compact script for presenting the ExoHabitability Advisor to an
academic panel. It focuses on the Prolog expert-system reasoning, because the
main assessment value is in facts, rules, deduction, backtracking, cut,
negation, lists, recursion, and dynamic knowledge bases.

---

## 0. Before the Demo

Open a terminal at the project root:

```bash
cd /Users/shakil/Dev/expert-system
swipl prolog/main.pl
```

Keep these files open in an editor:

- `prolog/facts.pl`
- `prolog/rules.pl`
- `prolog/classifications.pl`
- `prolog/explanations.pl`
- `prolog/lists.pl`
- `prolog/recursion.pl`
- `prolog/negation.pl`
- `prolog/dynamic_kb.pl`
- `prolog/planning.pl`

---

## 1. Timing Plan

| Time | Focus | What to show |
|---|---|---|
| 0:00-0:40 | Problem and architecture | Explain that this is a Prolog expert system for exoplanet habitability |
| 0:40-1:30 | Knowledge base and rules | Show facts and the main `habitable/1` rule |
| 1:30-2:40 | Live classification | Run `classification(kepler_442b, X).` and explain the derivation |
| 2:40-3:25 | Explanation system | Run `explain(kepler_442b).` |
| 3:25-4:20 | Course concepts | Show lists, recursion, negation, dynamic updates |
| 4:20-5:00 | Bonus planning and closing | Show state-space plan, summarize learning outcomes |

---

## 2. Opening Script

Say:

> This project is an AI expert system called ExoHabitability Advisor. It uses
> SWI-Prolog to classify planets as habitable, possibly habitable, terraforming
> candidates, or uninhabitable. The important point is that the answer is not a
> black box: every conclusion is derived from visible facts and rules, and the
> system can explain the reasoning steps.

Then show `prolog/main.pl`.

Mention:

- `facts.pl` stores the planet knowledge base.
- `rules.pl` contains expert rules such as size, temperature, and radiation.
- `classifications.pl` makes the final decision using a priority order and cut.
- `explanations.pl` converts the proof into readable reasons and concerns.
- Other modules demonstrate lists, recursion, negation, dynamic facts, I/O, and
  state-space planning.

---

## 3. Knowledge Base

Show `prolog/facts.pl`.

Point to one planet:

```prolog
planet(kepler_442b).
star_type(kepler_442b, k_type).
radius(kepler_442b, 1.34).
mass(kepler_442b, 2.3).
temperature(kepler_442b, 233).
in_habitable_zone(kepler_442b).
has_water_indicator(kepler_442b).
atmosphere(kepler_442b, likely).
radiation_level(kepler_442b, moderate).
```

Say:

> These are ground facts. There is no inference here yet. The system knows 12
> planets, including Earth, Mars, Proxima Centauri b, Kepler-442b,
> TRAPPIST-1e, Kepler-452b, Venus, Gliese 667Cc, Kepler-22b, TRAPPIST-1d,
> Luyten b, and Teegarden b.

---

## 4. Expert Rules

Show `prolog/rules.pl`.

Key rule:

```prolog
habitable(P) :-
    in_habitable_zone(P),
    earth_like_size(P),
    safe_temperature(P),
    has_water_indicator(P),
    atmosphere(P, likely),
    low_radiation(P).
```

Say:

> This is a Horn clause. `P` is habitable only if all six subgoals succeed.
> Prolog solves them from left to right. If any subgoal fails, the whole rule
> fails and Prolog backtracks.

Also mention:

```prolog
low_radiation(P) :-
    radiation_level(P, low).
low_radiation(P) :-
    radiation_level(P, moderate).
```

Say:

> This demonstrates logical OR through multiple clauses. Low radiation succeeds
> for either `low` or `moderate`.

---

## 5. Main Live Demo: Classification

In SWI-Prolog, run:

```prolog
?- classification(kepler_442b, X).
```

Expected:

```prolog
X = habitable.
```

Explain the derivation:

1. The query matches `classification(Planet, Class)`.
2. Variable substitution gives `Planet = kepler_442b` and `Class = X`.
3. The system calls `classify(kepler_442b, Derived)`.
4. The first classification rule tries `habitable(kepler_442b)`.
5. `habitable/1` creates six subgoals:
   - `in_habitable_zone(kepler_442b)`
   - `earth_like_size(kepler_442b)`
   - `safe_temperature(kepler_442b)`
   - `has_water_indicator(kepler_442b)`
   - `atmosphere(kepler_442b, likely)`
   - `low_radiation(kepler_442b)`
6. All succeed.
7. Inside `low_radiation/1`, the `low` clause fails, then Prolog backtracks to
   the `moderate` clause, which succeeds.
8. The cut `!` commits to `habitable`, preventing weaker categories from being
   considered.
9. Final substitution gives `X = habitable`.

Show `prolog/classifications.pl`:

```prolog
classify(P, habitable) :-
    habitable(P),
    !.

classify(P, possible_habitable) :-
    in_habitable_zone(P),
    safe_temperature(P),
    !.

classify(P, terraforming_candidate) :-
    atmosphere(P, none),
    !.

classify(_, uninhabitable).
```

Say:

> The cut gives a priority order: habitable first, then possibly habitable, then
> terraforming candidate, then uninhabitable. So each planet receives exactly
> one final category.

Optional contrast query:

```prolog
?- classification(kepler_452b, X).
```

Expected:

```prolog
X = possible_habitable.
```

Say:

> Kepler-452b is in the habitable zone and has a safe temperature, but it lacks
> a water-indicator fact. So the full `habitable/1` proof fails, Prolog
> backtracks, and the second classification rule succeeds.

---

## 6. Explanation System

Run:

```prolog
?- explain(kepler_442b).
```

Expected summary:

```text
Supporting factors:
  + Located in habitable zone
  + Earth-like size (rocky world)
  + Temperature suitable for liquid water
  + Water indicators detected
  + Atmosphere likely present
  + Acceptable radiation environment
Concerns:
  (none)
Classification: Habitable
```

Say:

> The explanation is generated from rules such as `reason/2` and `concern/2`.
> It is not just a manually written paragraph. Prolog backtracks over all
> matching explanation clauses to list the applicable reasons.

For a planet with concerns:

```prolog
?- explain(venus).
```

Say:

> Venus shows why explanation matters: it has some known facts, but the
> temperature and zone conditions fail, so the final verdict becomes
> uninhabitable.

---

## 7. Lists

Run:

```prolog
?- candidate_planets(L).
```

Expected:

```prolog
L = [earth, proxima_centauri_b, kepler_442b, trappist_1e, kepler_452b,
     gliese_667cc, kepler_22b, trappist_1d, luyten_b, teegarden_b].
```

Run:

```prolog
?- candidate_count(N).
```

Expected:

```prolog
N = 10.
```

Say:

> The list module demonstrates `member/2`, `append/3`, and `length/2`.
> `candidate_planets/1` gathers all planets classified as either habitable or
> possibly habitable.

---

## 8. Recursion

Run:

```prolog
?- planet_path(earth, kepler_442b, Path).
```

Expected:

```prolog
Path = [earth, luyten_b, teegarden_b, gliese_667cc, kepler_442b].
```

Say:

> This is a recursive graph search. The base case is reaching the goal planet.
> The recursive case moves to a neighbor and continues searching, while a
> visited list prevents cycles.

Run:

```prolog
?- reachable_candidate(earth, X).
```

Press `;` once or twice to show backtracking through multiple reachable
candidate planets.

---

## 9. Negation as Failure

Run:

```prolog
?- demonstrate_negation.
```

Say:

> Prolog uses negation as failure. `\+ habitable(venus)` succeeds because
> Prolog cannot prove `habitable(venus)` from the knowledge base. This is a
> closed-world assumption: what cannot be proven is treated as false.

Important examples:

```prolog
not_habitable(venus).
no_atmosphere(mars).
not_in_zone(venus).
```

---

## 10. Dynamic Knowledge Base

Run:

```prolog
?- demonstrate_dynamic.
```

Say:

> This demonstrates runtime knowledge-base manipulation. The system adds a new
> planet using `assertz/1`, classifies it immediately, changes its temperature
> using `retract/1` plus `assertz/1`, and finally removes it using
> `retractall/1`.

Key idea:

> Because the predicates in `facts.pl` are declared dynamic, newly asserted
> facts are immediately available to all rules without restarting Prolog.

---

## 11. Bonus: State-Space Planning

Run:

```prolog
?- survey_plan(kepler_442b, Plan).
```

Expected:

```prolog
Plan = [scan, analyze, classify].
```

Or run:

```prolog
?- survey(kepler_442b).
```

Say:

> This bonus module models classical AI planning. A planet moves through states:
> discovered, scanned, analyzed, and classified. The final `classify` action
> invokes the expert system, so the planning component is connected to the
> habitability rules.

---

## 12. Closing Script

Say:

> In summary, the project demonstrates a complete Prolog expert system. The
> knowledge base stores factual observations about planets. The inference engine
> derives habitability using Horn clauses. The classification engine uses cut to
> enforce deterministic priority. The explanation system exposes the reasoning,
> while the additional modules demonstrate list processing, recursion,
> backtracking, negation as failure, dynamic database updates, interactive I/O,
> and state-space search.

Final line:

> The main strength of this system is explainability: the panel can inspect each
> conclusion as a chain of facts, rules, substitutions, subgoals, and
> backtracking decisions.

---

## Fast Query Cheat Sheet

Use these if time becomes short:

```prolog
?- classification(kepler_442b, X).
?- explain(kepler_442b).
?- candidate_planets(L).
?- planet_path(earth, kepler_442b, Path).
?- demonstrate_negation.
?- demonstrate_dynamic.
?- survey_plan(kepler_442b, Plan).
```

---

## Panel Questions You Can Answer

**Why Prolog?**

Because Prolog naturally represents facts and Horn-clause rules, then performs
deductive reasoning through unification, goal matching, and backtracking.

**Where is backtracking visible?**

In `low_radiation/1`, Prolog first tries `radiation_level(P, low)` and then
backtracks to `radiation_level(P, moderate)`. It is also visible when
enumerating planets with queries like `habitable(X)`.

**Why use cut?**

The cut in `classify/2` commits to the first successful category, enforcing the
priority order and preventing one planet from receiving multiple categories.

**What makes it an expert system?**

It has a knowledge base, an inference engine, a consultation interface, and an
explanation system that shows how conclusions were reached.

**What is the limitation?**

The facts are simplified and educational. The system is designed to demonstrate
logic programming concepts, not to replace real astrophysical modeling.
