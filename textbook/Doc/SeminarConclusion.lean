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

#doc (Manual) "Conclusion" =>
%%%
tag := "seminar-conclusion"
%%%

When working with typeclasses in Mathlib, keep the following in mind.

Typeclasses can reduce code duplication and capture essential patterns in
mathematics, as we saw with `SetLike` and `MonoidHomClass`.

But we must be careful about *how* we declare our typeclasses, for performance
reasons:

* *Bundled vs. unbundled*: when integrating the algebra, order, topology, and
  normed hierarchies.
* *Priorities*: when registering instances such as `Algebra.id` and
  `ESeminormedAddMonoid.toAddMonoid`.

We must also watch out for bad {tech}[diamond]s, like the one encountered in the
interaction between `TopologicalSpace`, `MetricSpace`, and `Prod`. In such cases
we should stick as closely as possible to {tech}[forgetful inheritance] when
extending poorer typeclasses to richer ones.

Finally, one should be aware of {tech}[type synonym]s such as `OrderDual`,
`MulOpposite`, and the topology notation `IsOpen[·]`.
