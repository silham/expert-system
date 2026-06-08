# Derivation Trees & Reasoning Trace

This document answers the lecturer's required demonstration for the query

```prolog
?- classification(kepler_442b, X).
```

covering, in order:

1. Which rule matched
2. Variable substitutions performed
3. Generated sub-goals
4. Backtracking behaviour
5. Final conclusion

It also walks a second query that **does** backtrack, so the contrast is clear.

---

## 1. The relevant clauses

From `classifications.pl`:

```prolog
classification(Planet, Class) :-      % (C0) public entry
    classify(Planet, Derived),
    Class = Derived.

classify(P, habitable) :-             % (C1)
    habitable(P), !.
classify(P, possible_habitable) :-    % (C2)
    in_habitable_zone(P), safe_temperature(P), !.
classify(P, terraforming_candidate) :-% (C3)
    atmosphere(P, none), !.
classify(_, uninhabitable).           % (C4)
```

From `rules.pl`:

```prolog
habitable(P) :-
    in_habitable_zone(P),
    earth_like_size(P),
    safe_temperature(P),
    has_water_indicator(P),
    atmosphere(P, likely),
    low_radiation(P).

earth_like_size(P)  :- radius(P, R), R >= 0.5, R =< 1.8.
safe_temperature(P) :- temperature(P, T), T >= 180, T =< 320.
low_radiation(P)    :- radiation_level(P, low).
low_radiation(P)    :- radiation_level(P, moderate).
```

Relevant facts for `kepler_442b` (`facts.pl`):

```prolog
in_habitable_zone(kepler_442b).
radius(kepler_442b, 1.34).
temperature(kepler_442b, 233).
has_water_indicator(kepler_442b).
atmosphere(kepler_442b, likely).
radiation_level(kepler_442b, moderate).
```

---

## 2. Goal matching & variable substitution

Query: `classification(kepler_442b, X)`.

**Step 1 — match (C0).** Head `classification(Planet, Class)` unifies with the
goal:

```
Planet = kepler_442b
Class   = X            (X still unbound)
```

Body becomes two sub-goals:

```
classify(kepler_442b, Derived),  X = Derived
```

**Step 2 — solve `classify(kepler_442b, Derived)`.** Prolog tries the
`classify` clauses top-to-bottom.

- Try **(C1)** `classify(P, habitable)`. Head unifies with
  `P = kepler_442b`, `Derived = habitable`. New sub-goal:
  `habitable(kepler_442b), !`.

---

## 3. Generated sub-goals — proving `habitable(kepler_442b)`

`habitable/1` expands into a **conjunction** of six sub-goals, solved
left-to-right (this is the derivation tree):

```
habitable(kepler_442b)
├── in_habitable_zone(kepler_442b)         ✔ fact
├── earth_like_size(kepler_442b)
│   ├── radius(kepler_442b, R) ⇒ R = 1.34  ✔ fact
│   ├── 1.34 >= 0.5                         ✔
│   └── 1.34 =< 1.8                         ✔
├── safe_temperature(kepler_442b)
│   ├── temperature(kepler_442b, T) ⇒ T=233 ✔ fact
│   ├── 233 >= 180                          ✔
│   └── 233 =< 320                          ✔
├── has_water_indicator(kepler_442b)       ✔ fact
├── atmosphere(kepler_442b, likely)        ✔ fact
└── low_radiation(kepler_442b)
    └── (1st clause) radiation_level(kepler_442b, low)      -- FAILS (it is moderate)
        ⇒ backtrack to 2nd clause
        (2nd clause) radiation_level(kepler_442b, moderate) ✔ fact
```

Every sub-goal succeeds, so `habitable(kepler_442b)` **succeeds**.

Note the small **backtrack inside `low_radiation/1`**: the first clause
(`...low`) fails, Prolog backtracks and the second clause (`...moderate`)
succeeds. This is disjunction expressed as two clauses.

---

## 4. The cut, and why there is no further backtracking

Back in **(C1)**: after `habitable(kepler_442b)` succeeds, the `!` (cut)
executes. The cut **commits** to clause (C1):

- it discards the alternative `classify` clauses (C2, C3, C4), and
- it fixes `Derived = habitable`.

So `classify(kepler_442b, Derived)` returns `Derived = habitable`
**deterministically** — the lower-priority categories can never be reached for
this planet.

**Step 3 — finish (C0).** `X = Derived` gives:

```
X = habitable
```

### Final conclusion

```prolog
?- classification(kepler_442b, X).
X = habitable.
```

The reasoning, in one sentence: *kepler_442b is in its star's habitable zone,
Earth-like in size (R = 1.34), temperate (233 K), shows water, likely has an
atmosphere, and has acceptable (moderate) radiation — so the full `habitable/1`
rule succeeds, and the cut commits the classification to `habitable`.*

---

## 5. A query that backtracks between categories

```prolog
?- classification(kepler_452b, Y).
Y = possible_habitable.
```

`kepler_452b` has **no `has_water_indicator` fact**. Trace of `classify`:

```
classify(kepler_452b, Derived)
├── (C1) classify(_, habitable):
│        habitable(kepler_452b)
│        ├── in_habitable_zone ✔
│        ├── earth_like_size (R=1.63) ✔
│        ├── safe_temperature (265K) ✔
│        └── has_water_indicator(kepler_452b)  ✗ FAILS  ── no such fact
│        ⇒ habitable/1 fails ⇒ (C1) fails (the cut is never reached)
│        ⇒ BACKTRACK to next clause
├── (C2) classify(_, possible_habitable):
│        in_habitable_zone(kepler_452b) ✔
│        safe_temperature(kepler_452b)  ✔
│        !                              ── commit
│        ⇒ Derived = possible_habitable
└── (C3),(C4) never tried (cut removed them)
```

Final substitution `Y = possible_habitable`.

This shows the difference between **failure-driven backtracking between
clauses** (C1 → C2 here) and the **cut** that stops it once a clause commits.

---

## 6. Backtracking to enumerate solutions

`habitable/1` used with an unbound argument enumerates every habitable world by
backtracking on `planet/1`:

```prolog
?- planet(X), habitable(X).
X = earth ;
X = kepler_442b ;
X = trappist_1e ;
X = luyten_b ;
X = teegarden_b ;
false.
```

Each `;` is the user forcing backtracking; Prolog re-satisfies `planet(X)` with
the next planet and re-runs the `habitable/1` proof tree shown in §3.
