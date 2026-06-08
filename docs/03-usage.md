# Usage Guide

## Prerequisites

- **SWI-Prolog** (the reasoning engine)
  ```bash
  brew install swi-prolog      # macOS
  swipl --version              # verify
  ```
- **Python 3** (only for the GUI, Phase 11)

---

## 1. Running the Prolog system (command line)

Load the whole expert system with one command:

```bash
swipl prolog/main.pl
```

You'll see a banner. Type `help.` for the command menu. Useful queries:

```prolog
?- classification(kepler_442b, X).        % X = habitable.
?- explain(venus).                        % full reasoning report
?- candidate_planets(L).                  % the 10 habitability candidates
?- habitable(X).                          % backtrack through habitable worlds
?- demonstrate_negation.                  % negation-as-failure demo (Phase 8)
?- demonstrate_dynamic.                   % runtime add/update/remove (Phase 9)
?- explore(state(earth, discovered)).     % state-space planner (Phase 12)
?- consultation.                          % interactive session
```

To leave SWI-Prolog: `halt.`

### Interactive consultation (Phase 10)

```prolog
?- consultation.
> kepler_442b.      % a planet name FOLLOWED BY A PERIOD
> list.             % show all known planets
> quit.             % exit
```

---

## 2. Running the GUI (Phase 11)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r python/requirements.txt
streamlit run python/app.py
```

This opens `http://localhost:8501`. Features:

- **Select planet** — sidebar dropdown
- **View facts** — attribute table
- **Run classification** — colour-coded verdict
- **View explanation** — supporting factors + concerns
- **Add / remove planets** — sidebar forms (runtime `assert`/`retract`)
- **Run a raw Prolog query** — advanced expander

The Prolog engine is created once per session, so planets you add through the UI
persist until you stop the app.

---

## 3. Quick self-test (no GUI)

Verify the engine end-to-end from the shell:

```bash
swipl -q -g "
  classification(kepler_442b, X), writeln(X),
  findall(P,(planet(P),habitable(P)),L), writeln(L)
" -t halt prolog/main.pl
```

Expected:

```
habitable
[earth,kepler_442b,trappist_1e,luyten_b,teegarden_b]
```

---

## 4. Module load order

`main.pl` loads modules in dependency order:

```
facts → rules → classifications → explanations
      → lists → recursion → negation → dynamic_kb
      → consultation → planning
```

You can also load a single module plus its dependencies for focused testing,
e.g.:

```bash
swipl prolog/facts.pl prolog/rules.pl prolog/classifications.pl
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `swipl: command not found` | `brew install swi-prolog` |
| GUI: `Could not find SWI-Prolog` | ensure `swipl` is on `PATH` before launching Streamlit |
| `pip install pyswip` fails | confirm SWI-Prolog is installed first; it provides the native library PySwip binds to |
| Added planet disappears in GUI | it persists only while the app runs (in-memory dynamic facts) |
