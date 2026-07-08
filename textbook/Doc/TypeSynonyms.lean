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

#doc (Manual) "Type Synonyms" =>
%%%
tag := "type-synonyms"
shortTitle := "Type Synonyms"
%%%

When deciding whether a mathematical notion should be a `class` or a `structure`,
the choice often comes down to recognising whether:

* we are dealing with a *property* of a type that we want to use implicitly, which
  suggests a `class`; or
* we are working with an *object* belonging to a family of objects, which suggests
  a `structure`.

Think about `Group` and `Subgroup`. We use `Group` when we want to work with the
properties of groups, and `Subgroup` when we want to talk about the lattice of
subgroups of a group.

But what if we want to equip *the same type* with different properties, or to
explore the interactions between those properties?

# Non-Standard Topologies
%%%
tag := "type-synonyms-topology"
%%%

In topology, we usually fix a specific topology. Sometimes, though, we want to
reason about non-standard topologies on a type — and even about their
interactions:

```
def indiscreteTopology : TopologicalSpace ℕ := ⊤
def discreteTopology : TopologicalSpace ℕ := ⊥

example : ¬ IsOpen[indiscreteTopology] {1} := by
  intro contr
  have := TopologicalSpace.isOpen_top_iff {1}
  simp only [singleton_ne_empty, singleton_ne_univ, or_self, iff_false] at this
  contradiction

example : IsOpen[discreteTopology] {1} := by
  exact trivial
```

# The Dual Order
%%%
tag := "type-synonyms-order-dual"
%%%

Consider the natural numbers, `ℕ`. One can use the usual ordering:

```
example : (0 : ℕ) ≤ (1 : ℕ) := by decide
```

But it is also possible to equip the same type with the *dual* order. Since we do
not want competing instances on one type, the solution is a {deftech}_type
synonym_ such as `OrderDual`, with handy notation (`ᵒᵈ`) to tell the two apart:

```
open OrderDual

instance OrderDual.instOfNatNat (n : ℕ) : OfNat ℕᵒᵈ n where
  ofNat := n

example : (1 : ℕᵒᵈ) ≤ (0 : ℕᵒᵈ) := by decide
```

# Group Actions
%%%
tag := "type-synonyms-actions"
%%%

Similarly, type synonyms let us distinguish left and right group actions. Using
`MulOpposite` (written `ᵐᵒᵖ`), the same `•` notation denotes the left action on
`G` and the right action on `Gᵐᵒᵖ`:

```
variable {G : Type*} [Group G]

/- Left action -/
example (g x : G) : g • x = g * x :=
  rfl

open MulOpposite

/- Right action -/
example (g : Gᵐᵒᵖ) (x : G) : g • x = x * (unop g) :=
  rfl
```

Type synonyms such as `OrderDual`, `MulOpposite`, and the topology notation
`IsOpen[·]` let us carry several distinct structures on one underlying type
without confusing instance resolution.
