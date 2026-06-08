% =============================================================================
% facts.pl  --  ExoHabitability Advisor : Planet Knowledge Base (Phase 2)
% =============================================================================
%
% This module holds the FACTUAL knowledge base only (no rules / no inference).
% Each planet is described by a set of ground facts using these predicates:
%
%   planet(P)                  - P is a known planet
%   star_type(P, Type)         - spectral class of the host star
%   radius(P, R)               - radius in Earth radii  (Earth = 1.0)
%   mass(P, M)                 - mass in Earth masses    (Earth = 1.0)
%   temperature(P, T)          - estimated equilibrium / surface temp in Kelvin
%   in_habitable_zone(P)       - lies within its star's habitable zone
%   has_water_indicator(P)     - spectroscopic / model evidence of water
%   atmosphere(P, Status)      - one of: likely | thin | thick | none
%   radiation_level(P, Level)  - one of: low | moderate | high
%
% The predicates are declared `dynamic` so Phase 9 can assert/retract planets
% at runtime without "Unknown procedure" errors when a planet has no facts yet.
% =============================================================================

:- dynamic planet/1.
:- dynamic star_type/2.
:- dynamic radius/2.
:- dynamic mass/2.
:- dynamic temperature/2.
:- dynamic in_habitable_zone/1.
:- dynamic has_water_indicator/1.
:- dynamic atmosphere/2.
:- dynamic radiation_level/2.

% Facts below are grouped BY PLANET (one block per world) for readability,
% which interleaves predicates. `discontiguous` tells SWI-Prolog this is
% intentional and suppresses the "clauses not together" warnings.
:- discontiguous planet/1.
:- discontiguous star_type/2.
:- discontiguous radius/2.
:- discontiguous mass/2.
:- discontiguous temperature/2.
:- discontiguous in_habitable_zone/1.
:- discontiguous has_water_indicator/1.
:- discontiguous atmosphere/2.
:- discontiguous radiation_level/2.

% -----------------------------------------------------------------------------
% 1. EARTH  -- reference world; the textbook "habitable" case
% -----------------------------------------------------------------------------
planet(earth).
star_type(earth, g_type).
radius(earth, 1.0).
mass(earth, 1.0).
temperature(earth, 288).
in_habitable_zone(earth).
has_water_indicator(earth).
atmosphere(earth, likely).
radiation_level(earth, low).

% -----------------------------------------------------------------------------
% 2. MARS  -- cold, near-vacuum air; a classic terraforming candidate
% -----------------------------------------------------------------------------
planet(mars).
star_type(mars, g_type).
radius(mars, 0.53).
mass(mars, 0.11).
temperature(mars, 210).
% NOT in habitable zone (sits just beyond the conservative outer edge).
has_water_indicator(mars).            % subsurface / polar ice
atmosphere(mars, none).               % ~0.6% of Earth's pressure => "none"
radiation_level(mars, high).          % no magnetosphere, thin air

% -----------------------------------------------------------------------------
% 3. PROXIMA CENTAURI b  -- right temp & zone, but a violent flare star
% -----------------------------------------------------------------------------
planet(proxima_centauri_b).
star_type(proxima_centauri_b, m_type).
radius(proxima_centauri_b, 1.07).
mass(proxima_centauri_b, 1.17).
temperature(proxima_centauri_b, 234).
in_habitable_zone(proxima_centauri_b).
has_water_indicator(proxima_centauri_b).
atmosphere(proxima_centauri_b, likely).
radiation_level(proxima_centauri_b, high).   % stellar flares => fails "habitable"

% -----------------------------------------------------------------------------
% 4. KEPLER-442b  -- one of the strongest real habitability candidates
% -----------------------------------------------------------------------------
planet(kepler_442b).
star_type(kepler_442b, k_type).
radius(kepler_442b, 1.34).
mass(kepler_442b, 2.3).
temperature(kepler_442b, 233).
in_habitable_zone(kepler_442b).
has_water_indicator(kepler_442b).
atmosphere(kepler_442b, likely).
radiation_level(kepler_442b, moderate).

% -----------------------------------------------------------------------------
% 5. TRAPPIST-1e  -- Earth-sized, in the zone, prime candidate
% -----------------------------------------------------------------------------
planet(trappist_1e).
star_type(trappist_1e, m_type).
radius(trappist_1e, 0.92).
mass(trappist_1e, 0.69).
temperature(trappist_1e, 250).
in_habitable_zone(trappist_1e).
has_water_indicator(trappist_1e).
atmosphere(trappist_1e, likely).
radiation_level(trappist_1e, moderate).

% -----------------------------------------------------------------------------
% 6. KEPLER-452b  -- "Earth's cousin", but no firm water evidence
% -----------------------------------------------------------------------------
planet(kepler_452b).
star_type(kepler_452b, g_type).
radius(kepler_452b, 1.63).
mass(kepler_452b, 5.0).
temperature(kepler_452b, 265).
in_habitable_zone(kepler_452b).
% has_water_indicator/1 deliberately ABSENT => fails full "habitable" rule.
atmosphere(kepler_452b, likely).
radiation_level(kepler_452b, moderate).

% -----------------------------------------------------------------------------
% 7. VENUS  -- in/near the zone but a runaway greenhouse; uninhabitable
% -----------------------------------------------------------------------------
planet(venus).
star_type(venus, g_type).
radius(venus, 0.95).
mass(venus, 0.82).
temperature(venus, 737).              % far above safe range
% NOT in habitable zone (inner edge).
atmosphere(venus, thick).             % crushing CO2 atmosphere
radiation_level(venus, moderate).

% -----------------------------------------------------------------------------
% 8. GLIESE 667Cc  -- good temp & zone, high radiation from M-dwarf host
% -----------------------------------------------------------------------------
planet(gliese_667cc).
star_type(gliese_667cc, m_type).
radius(gliese_667cc, 1.5).
mass(gliese_667cc, 3.8).
temperature(gliese_667cc, 277).
in_habitable_zone(gliese_667cc).
has_water_indicator(gliese_667cc).
atmosphere(gliese_667cc, likely).
radiation_level(gliese_667cc, high).         % fails "habitable" on radiation

% -----------------------------------------------------------------------------
% 9. KEPLER-22b  -- in the zone & temperate, but too large (mini-Neptune?)
% -----------------------------------------------------------------------------
planet(kepler_22b).
star_type(kepler_22b, g_type).
radius(kepler_22b, 2.4).               % > 1.8 => fails earth_like_size
mass(kepler_22b, 9.1).
temperature(kepler_22b, 262).
in_habitable_zone(kepler_22b).
has_water_indicator(kepler_22b).
atmosphere(kepler_22b, likely).
radiation_level(kepler_22b, low).

% -----------------------------------------------------------------------------
% 10. TRAPPIST-1d  -- temperate & in zone, but only a thin atmosphere
% -----------------------------------------------------------------------------
planet(trappist_1d).
star_type(trappist_1d, m_type).
radius(trappist_1d, 0.78).
mass(trappist_1d, 0.39).
temperature(trappist_1d, 288).
in_habitable_zone(trappist_1d).
has_water_indicator(trappist_1d).
atmosphere(trappist_1d, thin).               % fails "habitable" on atmosphere
radiation_level(trappist_1d, moderate).

% -----------------------------------------------------------------------------
% 11. LUYTEN b (GJ 273b)  -- nearby super-Earth, solid all-round candidate
% -----------------------------------------------------------------------------
planet(luyten_b).
star_type(luyten_b, m_type).
radius(luyten_b, 1.1).
mass(luyten_b, 2.9).
temperature(luyten_b, 259).
in_habitable_zone(luyten_b).
has_water_indicator(luyten_b).
atmosphere(luyten_b, likely).
radiation_level(luyten_b, moderate).

% -----------------------------------------------------------------------------
% 12. TEEGARDEN b  -- very high Earth-similarity index candidate
% -----------------------------------------------------------------------------
planet(teegarden_b).
star_type(teegarden_b, m_type).
radius(teegarden_b, 1.05).
mass(teegarden_b, 1.05).
temperature(teegarden_b, 300).
in_habitable_zone(teegarden_b).
has_water_indicator(teegarden_b).
atmosphere(teegarden_b, likely).
radiation_level(teegarden_b, moderate).

% =============================================================================
% End of facts.pl  --  12 planets defined (requirement: >= 10).
% =============================================================================
