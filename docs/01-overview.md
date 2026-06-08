# ExoHabitability Advisor — System Overview

An AI expert system in **SWI-Prolog** that evaluates the habitability of
exoplanets through deductive reasoning, with a **Streamlit/PySwip** GUI.

The system is intentionally a **glass box**: every verdict is accompanied by the
exact facts and rules that produced it.

---

## Architecture

```
exo-habitability-advisor/
├── prolog/                      The expert system (knowledge + inference)
│   ├── facts.pl                 Phase 2  — planet facts (12 planets, dynamic)
│   ├── rules.pl                 Phase 3  — habitable/1 and sub-rules
│   ├── classifications.pl       Phase 4  — classification/2 (uses cut)
│   ├── explanations.pl          Phase 5  — reason/2, concern/2, explain/1
│   ├── lists.pl                 Phase 6  — candidate_planets/1, member/append/length
│   ├── recursion.pl             Phase 7  — reachable/2, planet_path/3
│   ├── negation.pl              Phase 8  — not_habitable/1 (\+)
│   ├── dynamic_kb.pl            Phase 9  — add_planet/remove_planet (assert/retract)
│   ├── consultation.pl          Phase 10 — interactive read/write loop
│   ├── planning.pl              Phase 12 — state-space planner (explore/1)
│   └── main.pl                  Loader — `swipl prolog/main.pl`
│
├── python/
│   ├── app.py                   Phase 11 — Streamlit GUI over PySwip
│   └── requirements.txt
│
└── docs/                        This documentation
```

The Prolog files are kept **modular** (one concept per file). `main.pl` loads
them in dependency order. The Python GUI performs **no reasoning of its own** —
it only sends queries to the Prolog engine and renders the answers.

---

## Data model (facts)

Each planet is described by these predicates (see `facts.pl`):

| Predicate | Meaning |
|---|---|
| `planet(P)` | P is a known planet |
| `star_type(P, T)` | host-star spectral class |
| `radius(P, R)` | radius in Earth radii |
| `mass(P, M)` | mass in Earth masses |
| `temperature(P, T)` | temperature in Kelvin |
| `in_habitable_zone(P)` | lies in the star's habitable zone |
| `has_water_indicator(P)` | evidence of water |
| `atmosphere(P, S)` | `likely \| thin \| thick \| none` |
| `radiation_level(P, L)` | `low \| moderate \| high` |

The 12 planets: earth, mars, proxima_centauri_b, kepler_442b, trappist_1e,
kepler_452b, venus, gliese_667cc, kepler_22b, trappist_1d, luyten_b,
teegarden_b.

---

## Reasoning pipeline

```
facts ──▶ sub-rules ──▶ habitable/1 ──▶ classification/2 ──▶ explain/1
          (size,         (the main      (4-way, priority    (reasons +
           temp,          expert rule)   via cut)            concerns)
           radiation)
```

**Classification categories** (priority order, enforced by cut):

1. `habitable` — passes the full `habitable/1` rule
2. `possible_habitable` — in zone & temperate, but not fully habitable
3. `terraforming_candidate` — airless (`atmosphere = none`)
4. `uninhabitable` — none of the above

Current results:

| Class | Planets |
|---|---|
| Habitable | earth, kepler_442b, trappist_1e, luyten_b, teegarden_b |
| Possibly Habitable | proxima_centauri_b, kepler_452b, gliese_667cc, kepler_22b, trappist_1d |
| Terraforming Candidate | mars |
| Uninhabitable | venus |

---

## Course concept → code map

| Concept | Where |
|---|---|
| Facts | `facts.pl` |
| Rules / Horn clauses | `rules.pl`, all `*.pl` |
| Predicate logic & arithmetic | `earth_like_size/1`, `safe_temperature/1` |
| Deductive reasoning | `habitable/1` chaining sub-goals |
| Query processing | `main.pl` entry points, GUI query box |
| Backtracking | `habitable(X)`, multi-clause `low_radiation/1` |
| Cut (`!`) | `classify/2` in `classifications.pl` |
| Negation as failure | `negation.pl` (`\+`) |
| Lists (`member/append/length`) | `lists.pl` |
| Recursion | `recursion.pl` (`reachable/2`, `planet_path/3`) |
| Dynamic KB (`assert`/`retract`) | `dynamic_kb.pl` |
| I/O (`read`/`write`/`nl`) | `consultation.pl` |
| Expert-system design | whole system |
| State-space search (bonus) | `planning.pl` |

See **02-derivation-trees.md** for the worked reasoning trace, and
**03-usage.md** for how to run everything.
