/-
Copyright (c) 2026 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import VersoManual
import Doc.Meta.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open Doc

set_option pp.rawOnError true
set_option verso.code.warnLineLength 0

#doc (Manual) "Hazards of Typeclass Use" =>
%%%
tag := "hazards"
shortTitle := "Hazards"
%%%

When building up mathematical structures, one often deals with diamond-like
hierarchies. We saw this, for instance, with the algebraic hierarchy.

![Algebraic hierarchy](../figures/HierarchyAlgebra.png)

If different paths through a diamond are *definitionally equal*, there is no
problem. However, it is easy to set up typeclasses so that a *bad* diamond is
produced.

![A topological diamond](../figures/TopDiamond.svg)

# A Bad Diamond
%%%
tag := "hazards-bad-diamond"
%%%

Consider synthesizing a `TopologicalSpace` instance on `α × β`, given two
`MetricSpace` instances. The "natural" set-up for the `MetricSpace` typeclass
would be:

```
class BadMetricSpace (α : Type u) : Type u extends Dist α where
  dist_self : ∀ x : α, dist x x = 0
  dist_comm : ∀ x y : α, dist x y = dist y x
  dist_triangle : ∀ x y z : α, dist x z ≤ dist x y + dist y z
  eq_of_dist_eq_zero {x y : α} : dist x y = 0 → x = y
```

Now consider the two paths:

* `MetricSpace α` → `TopologicalSpace α` → `TopologicalSpace (α × β)`
* `MetricSpace α` → `MetricSpace (α × β)` → `TopologicalSpace (α × β)`, where the
  product distance is

$$`d\bigl((a_1,b_1), (a_2, b_2)\bigr) = d_{\alpha}(a_1, a_2) \sqcup d_{\beta}(b_1, b_2)`

The two topologies are the same *mathematically*, but not *definitionally*. This
is a problem.

# The Fix
%%%
tag := "hazards-fix"
%%%

The fix is inspired by the algebraic hierarchy's {tech}[forgetful inheritance]. A
metric space should carry both a *distance*, a *topology*, and a *proof* that the
topology coincides with the one coming from the distance. We then define the
instance on `α × β` with the *supremum distance*, the *product topology*, and the
proof that they coincide. Both definitionally-equal paths then yield the product
topology on the product space.

Concretely, `PseudoMetricSpace` is set up to contain a `UniformSpace`, which in
turn contains a `TopologicalSpace`:

```
class PseudoMetricSpace (α : Type u) : Type u extends Dist α where
  dist_self : ∀ x : α, dist x x = 0
  dist_comm : ∀ x y : α, dist x y = dist y x
  dist_triangle : ∀ x y z : α, dist x z ≤ dist x y + dist y z
  edist : α → α → ENNReal := fun x y => ENNReal.ofNNReal (.mk (dist x y) (dist_nonneg' _ ‹_› ‹_› ‹_›))
  edist_dist : ∀ x y : α, edist x y = ENNReal.ofReal (dist x y) := by
    intro x y; exact ENNReal.coe_nnreal_eq _
  toUniformSpace : UniformSpace α := .ofDist dist dist_self dist_comm dist_triangle
  uniformity_dist : 𝓤 α = ⨅ ε > 0, 𝓟 { p : α × α | dist p.1 p.2 < ε } := by intros; rfl
  toBornology : Bornology α := Bornology.ofDist dist dist_comm dist_triangle
  cobounded_sets : (Bornology.cobounded α).sets =
    { s | ∃ C : ℝ, ∀ x ∈ sᶜ, ∀ y ∈ sᶜ, dist x y ≤ C } := by intros; rfl
```

The `toUniformSpace` field is the crucial one: by making the uniform (and hence
topological) structure part of the metric-space data, all paths through the
diamond agree by construction.
