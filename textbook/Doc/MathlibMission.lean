/-
Copyright (c) 2026 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import VersoManual
import Doc.Meta.Lean
import Mathlib.Order.Lattice
import Mathlib.Algebra.Group.Basic
import Mathlib.Algebra.Group.Int.Defs
import Mathlib.Data.Nat.Cast.Defs

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open Doc

set_option pp.rawOnError true
set_option verso.code.warnLineLength 0

#doc (Manual) "Mathlib's Mission and Design Considerations" =>
%%%
tag := "mathlib-mission"
shortTitle := "Mathlib's Mission"
%%%

These notes accompany the Lean Seminar 2026 talk on how to use typeclass
inference in Mathlib. We work through the following themes:

1. Mathlib, its mission, and design considerations
2. Typeclass use in Mathlib
3. Optimising typeclass synthesis in Mathlib
4. Hazards of typeclass use
5. Type synonyms

# Mathlib's Mission
%%%
tag := "mathlib-mission-statement"
%%%

One of Mathlib's aims is to *unify* different areas of mathematics into a
*convenient* mathematical library for formalising current research.

Downstream projects show why this matters:

* the formalisation of Fermat's Last Theorem, and
* Carleson's project on the convergence of Fourier series.

These efforts draw on number theory, linear algebra, algebraic geometry,
topology, and more. Such breadth calls for a genuinely unified library.

Mathematicians also want to leave routine arguments to the computer — this is
why tools like Lean are called *proof assistants*. In Carleson's project, for
instance, many proofs about measurability, continuity, and differentiability
were discharged automatically. This desire for *convenience* motivates powerful
automation such as `fun_prop`, and typeclass synthesis itself.

With this philosophy in mind, we explore how typeclasses are used in Mathlib and
the obstacles that arise along the way.
