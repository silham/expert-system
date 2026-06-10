"""
ExoHabitability Advisor -- Streamlit GUI (Phase 11)
===================================================

A thin graphical front-end over the SWI-Prolog expert system. ALL reasoning
happens in Prolog (prolog/main.pl); this file only:

  * sends queries to the Prolog engine via PySwip,
  * renders the facts, classification and explanation, and
  * lets the user add / remove planets at runtime (Phase 9 in action).

Run with:
    streamlit run python/app.py

The Prolog engine is created ONCE per session (st.cache_resource) so that
planets added through the UI persist across Streamlit's script re-runs.
"""

import os
import re
import threading
import streamlit as st
from pyswip import Prolog

# --- locate prolog/main.pl relative to this file -----------------------------
HERE = os.path.dirname(os.path.abspath(__file__))
MAIN_PL = os.path.join(HERE, "..", "prolog", "main.pl")

CLASS_COLORS = {
    "habitable": "🟢",
    "possible_habitable": "🟡",
    "terraforming_candidate": "🟠",
    "uninhabitable": "🔴",
}

PROLOG_LOCK = threading.RLock()


# =============================================================================
# Prolog bridge
# =============================================================================
@st.cache_resource
def get_engine():
    """Create and load the Prolog engine exactly once per Streamlit session."""
    prolog = Prolog()
    prolog.consult(MAIN_PL.replace("\\", "/"))
    return prolog


def _txt(v):
    """Normalise a PySwip value to a clean Python string."""
    if isinstance(v, bytes):
        return v.decode("utf-8")
    return str(v)


def _query(prolog, goal, maxresult=-1):
    """Run a Prolog query, materialise all rows, and always close it.

    PySwip allows only one active query at a time. Streamlit reruns the script
    often, so every query must be fully consumed and explicitly closed before
    another query starts.
    """
    with PROLOG_LOCK:
        q = prolog.query(goal, maxresult=maxresult)
        try:
            return list(q)
        finally:
            q.close()


def _has(prolog, goal):
    """True if `goal` has at least one solution."""
    return bool(_query(prolog, goal, maxresult=1))


def list_planets(prolog):
    rows = _query(prolog, "planet(P)")
    # preserve definition order, de-duplicate
    seen, out = set(), []
    for r in rows:
        p = _txt(r["P"])
        if p not in seen:
            seen.add(p)
            out.append(p)
    return out


def get_facts(prolog, planet):
    """Return a dict of the ground facts known about `planet`."""

    def one(goal, var, default="—"):
        res = _query(prolog, goal, maxresult=1)
        return res[0][var] if res else default

    return {
        "Star type": _txt(one(f"star_type({planet}, X)", "X")),
        "Radius (R⊕)": one(f"radius({planet}, X)", "X"),
        "Mass (M⊕)": one(f"mass({planet}, X)", "X"),
        "Temperature (K)": one(f"temperature({planet}, X)", "X"),
        "In habitable zone": "yes" if _has(prolog, f"in_habitable_zone({planet})") else "no",
        "Water indicator": "yes" if _has(prolog, f"has_water_indicator({planet})") else "no",
        "Atmosphere": _txt(one(f"atmosphere({planet}, X)", "X")),
        "Radiation level": _txt(one(f"radiation_level({planet}, X)", "X")),
    }


def classify(prolog, planet):
    res = _query(prolog, f"classification({planet}, C), class_label(C, L)", maxresult=1)
    if not res:
        return None, None
    return _txt(res[0]["C"]), _txt(res[0]["L"])


def reasons(prolog, planet):
    return [_txt(r["R"]) for r in _query(prolog, f"reason({planet}, R)")]


def concerns(prolog, planet):
    return [_txt(r["C"]) for r in _query(prolog, f"concern({planet}, C)")]


def candidates(prolog):
    res = _query(prolog, "candidate_planets(L)", maxresult=1)
    if not res:
        return []
    return [_txt(x) for x in res[0]["L"]]


def add_planet(prolog, name, star, radius, mass, temp, in_zone, water, atmo, rad):
    goal = (
        f"add_planet({name}, {star}, {radius}, {mass}, {temp}, "
        f"{'yes' if in_zone else 'no'}, {'yes' if water else 'no'}, {atmo}, {rad})"
    )
    return _has(prolog, goal)


def remove_planet(prolog, name):
    return _has(prolog, f"remove_planet({name})")


def sanitize_atom(name):
    """Turn user input into a valid lowercase Prolog atom (a..z,0..9,_)."""
    s = name.strip().lower()
    s = re.sub(r"[^a-z0-9_]+", "_", s)
    s = s.strip("_")
    if not s:
        return None
    if not s[0].isalpha():
        s = "p_" + s
    return s


# =============================================================================
# UI
# =============================================================================
st.set_page_config(page_title="ExoHabitability Advisor", page_icon="🪐", layout="wide")
prolog = get_engine()

st.title("🪐 ExoHabitability Advisor")
st.caption("A Prolog expert system for evaluating exoplanet habitability. "
           "All reasoning is performed in SWI-Prolog.")

# ---- Sidebar : selection + add/remove ---------------------------------------
with st.sidebar:
    st.header("Planet selection")
    planets = list_planets(prolog)
    selected = st.selectbox("Choose a planet", planets)

    st.divider()
    st.header("➕ Add a planet")
    with st.form("add_form", clear_on_submit=True):
        raw_name = st.text_input("Name", placeholder="e.g. new_eden")
        star = st.selectbox("Star type", ["g_type", "k_type", "m_type", "f_type"])
        radius = st.number_input("Radius (Earth radii)", 0.1, 20.0, 1.0, 0.05)
        mass = st.number_input("Mass (Earth masses)", 0.01, 50.0, 1.0, 0.1)
        temp = st.number_input("Temperature (K)", 0, 2000, 280, 5)
        in_zone = st.checkbox("In habitable zone", value=True)
        water = st.checkbox("Water indicator", value=True)
        atmo = st.selectbox("Atmosphere", ["likely", "thin", "thick", "none"])
        rad = st.selectbox("Radiation level", ["low", "moderate", "high"])
        submitted = st.form_submit_button("Add planet")
        if submitted:
            name = sanitize_atom(raw_name)
            if not name:
                st.error("Please enter a valid name.")
            elif name in planets:
                st.warning(f"'{name}' already exists.")
            else:
                ok = add_planet(prolog, name, star, radius, mass, temp,
                                in_zone, water, atmo, rad)
                if ok:
                    st.success(f"Added '{name}'. Select it above.")
                    st.rerun()
                else:
                    st.error("Could not add planet.")

    st.divider()
    st.header("🗑️ Remove a planet")
    rem = st.selectbox("Planet to remove", planets, key="rem")
    if st.button("Remove", type="secondary"):
        if remove_planet(prolog, rem):
            st.success(f"Removed '{rem}'.")
            st.rerun()
        else:
            st.error("Could not remove planet.")

# ---- Main : facts + classification + explanation ----------------------------
if not selected:
    st.info("Add or select a planet from the sidebar.")
    st.stop()

cls, label = classify(prolog, selected)
icon = CLASS_COLORS.get(cls, "⚪")

col1, col2 = st.columns([1, 1])

with col1:
    st.subheader(f"Facts: {selected}")
    facts = get_facts(prolog, selected)
    st.table({"Property": list(facts.keys()), "Value": [str(v) for v in facts.values()]})

with col2:
    st.subheader("Classification")
    st.markdown(f"## {icon} {label}")

    st.subheader("✅ Supporting factors")
    rs = reasons(prolog, selected)
    if rs:
        for r in rs:
            st.markdown(f"- {r}")
    else:
        st.markdown("_none_")

    st.subheader("⚠️ Concerns")
    cs = concerns(prolog, selected)
    if cs:
        for c in cs:
            st.markdown(f"- {c}")
    else:
        st.markdown("_none_")

# ---- Candidates overview -----------------------------------------------------
st.divider()
st.subheader("🛰️ Habitability candidates")
cand = candidates(prolog)
st.write(f"{len(cand)} candidate planet(s): " + ", ".join(cand) if cand else "None.")

# ---- Free-form query (advanced) ---------------------------------------------
st.divider()
with st.expander("🔍 Run a raw Prolog query"):
    st.caption("Example:  classification(P, habitable)   or   reachable_candidate(earth, X)")
    q = st.text_input("Query", value="classification(P, habitable)")
    if st.button("Run query"):
        try:
            results = _query(prolog, q)
            if not results:
                st.warning("No solutions (false).")
            else:
                st.success(f"{len(results)} solution(s):")
                st.json([{k: _txt(v) for k, v in sol.items()} for sol in results])
        except Exception as e:  # noqa: BLE001
            st.error(f"Query error: {e}")
