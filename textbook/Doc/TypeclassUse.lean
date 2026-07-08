/-
Copyright (c) 2026 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import VersoManual
import Doc.Meta.Lean
import Mathlib.Order.Lattice
import Mathlib.Algebra.Group.Subgroup.Defs
import Mathlib.Algebra.Group.Int.Defs
import Mathlib.Data.Nat.Cast.Defs
import Mathlib.Data.Multiset.Defs
import Mathlib.Data.Finset.Defs
import Mathlib.Order.Preorder.Chain
import Mathlib.Order.Filter.Defs

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open Doc

set_option pp.rawOnError true
set_option verso.code.warnLineLength 0

#doc (Manual) "Typeclass Use in Mathlib" =>
%%%
tag := "typeclass-use"
shortTitle := "Typeclass Use"
%%%

In mathematics, objects often have similar properties and behave in analogous
ways. Consider the structures {lean}`Set`, {lean}`Finset`, {lean}`Subgroup`,
{lean}`Submonoid`, {lean}`Flag`, and friends.

These structures all share lemmas such as the following characterisation of
strict inclusion:

```lean
example {S : Type*} {H K : Set S} : H < K ↔ H ≤ K ∧ ∃ x ∈ K, x ∉ H :=
  by simp [Set.lt_iff_ssubset, Set.ssubset_iff_exists]
example {G : Type*} [Group G] {H K : Subgroup G} : H < K ↔ H ≤ K ∧ ∃ x ∈ K, x ∉ H :=
  SetLike.lt_iff_le_and_exists
example {M : Type*} [Monoid M] {H K : Submonoid M} : H < K ↔ H ≤ K ∧ ∃ x ∈ K, x ∉ H :=
  SetLike.lt_iff_le_and_exists
```

That is a lot of duplicated code.

# The Problem, and a Familiar Solution
%%%
tag := "typeclass-use-problem"
%%%

*Problem*: maintaining all of these lemmas is tedious. When a refactor happens,
every one of them might need to be updated.

*Solution*: recall one of the crowning jewels of Mathlib's design.

Consider the {lean}`Filter` structure. Among other things, the {lean}`Filter`
abstraction reduced 512 lemmas about compositions of limits into a single lemma:

```lean
open Filter in
set_option linter.unusedVariables false in
variable {α β γ : Type*} in
theorem Tendsto.comp {f : α → β} {g : β → γ} {x : Filter α} {y : Filter β} {z : Filter γ}
    (hg : Tendsto g y z) (hf : Tendsto f x y) : Tendsto (g ∘ f) x z :=
  fun _ hs => hf (hg hs)
```

This deals with code duplication while capturing an essential pattern in
mathematics. Of course {lean}`Filter` is a *structure*, not a *typeclass* — but
we can do the same thing with typeclasses.

# `SetLike`
%%%
tag := "typeclass-use-setlike"
%%%

As you may have suspected, the structures {lean}`Set`, {lean}`Finset`,
{lean}`Subgroup`, {lean}`Submonoid`, {lean}`Flag`, and friends all look very
{lean}`SetLike`. Indeed, each has a registered {lean}`SetLike` instance, so it
suffices to prove the desired lemma once:

```lean
open SetLike in
variable {A B : Type*} [SetLike A B] [PartialOrder A] [IsConcreteLE A B] {p q : A} in
theorem lt_iff_le_and_exists : p < q ↔ p ≤ q ∧ ∃ x ∈ q, x ∉ p := by
  rw [lt_iff_le_not_ge, not_le_iff_exists]
```

Of course we do *not* register a {lean}`SetLike` instance on {lean}`Set` itself —
that would yield a cycle.

# `FunLike` and Morphism Classes
%%%
tag := "typeclass-use-funlike"
%%%

We can do the same for morphisms that extend these structures, such as the
{lean}`MonoidHom` structure. We create classes like `MonoidHomClass` and
`MulHomClass` which take the {lean}`FunLike` class as a *parameter*, giving
lemmas such as:

```lean
namespace TypeclassUse
variable {M : Type*} {N : Type*} {F : Type*}

theorem map_mul [Mul M] [Mul N] [FunLike F M N] [MulHomClass F M N] (f : F) (x y : M) :
    f (x * y) = f x * f y :=
  MulHomClass.map_mul f x y

theorem map_mul_eq_one [MulOneClass M] [MulOneClass N] [FunLike F M N] [MonoidHomClass F M N]
    (f : F) {a b : M} (h : a * b = 1) : f a * f b = 1 := by
  rw [← map_mul, h, map_one]

end TypeclassUse
```
