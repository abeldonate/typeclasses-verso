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
import Mathlib.Data.Multiset.Defs
import Mathlib.Data.Finset.Defs
import Mathlib.Algebra.Group.Hom.Defs
import Mathlib.Algebra.Field.Defs
import Mathlib.Analysis.Normed.Field.Basic

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open Doc

set_option pp.rawOnError true
set_option verso.code.warnLineLength 0

#doc (Manual) "Optimising Typeclass Synthesis in Mathlib" =>
%%%
tag := "optimising-synthesis"
shortTitle := "Optimising Synthesis"
%%%

Typeclasses like {lean}`SetLike`, {lean}`FunLike`, `EquivLike`, and
`MonoidHomClass` are extremely convenient and remove a great deal of code
duplication. As Mathlib scales, though, challenges arise: Mathlib must be *fast*.

Instance synthesis accounts for 10 to 25 percent of the build time of a typical
Mathlib file, and for the synthesis algorithm to *fail* it must have explored the
entire search space.

# Bundling vs. Unbundling
%%%
tag := "optimising-bundling"
%%%

Consider the following snippet:

```lean +error
inductive P
inductive Q
example (p : P) : Q := p
```

As expected, this results in an error. What was surprising at the time is that it
took 250ms to fail. Classes such as `MulHomClass` were then set up like this:

```
class MulHomClass (F : Type*) (M N : outParam (Type*)) [Mul M] [Mul N]
  extends DFunLike F M fun _ => N where
  ...
```

Peeking under the hood, once typeclass search triggered on `CoeT P p Q` and
applied `FunLike.hasCoeToFun`, it went wild trying every `toFunLike` instance:

```
[tryResolve] ✅ CoeFun P fun x ↦ (a : ?m.146) → ?m.147 a ≟ CoeFun P fun x ↦ (a : ?m.146) → ?m.147 a
[] new goal FunLike P _tc.2 _tc.3 ▼
  [instances] #[@ZeroHomClass.toFunLike, @AddHomClass.toFunLike, @OneHomClass.toFunLike,
   @MulHomClass.toFunLike, @EmbeddingLike.toFunLike, @RelHomClass.toFunLike, ...]
```

The solution was to take {lean}`FunLike` as a *parameter* rather than extending
it:

```
class MulHomClass (F : Type*) (M N : outParam Type*) [Mul M] [Mul N] [FunLike F M N] : Prop where
```

This refactor produced a 33 percent speed-up for typeclass instance synthesis and
a 19 percent decrease in build instructions overall. With the new setup, the
snippet above fails much faster.

# Interacting Hierarchies
%%%
tag := "optimising-hierarchies"
%%%

Consider mathematical objects with varying levels of structure:

* {lean}`Mul` < {lean}`Semigroup` < {lean}`Monoid` < {lean}`Group`
* {lean}`Preorder` < {lean}`PartialOrder` < {lean}`Lattice` < {lean}`LinearOrder`

These hierarchies are set up through {tech}[forgetful inheritance]. But how should
they *interact*? Suppose we must synthesize a {lean}`CommMonoid` instance. There
are two natural ways to set up the interaction between the algebraic and order
hierarchies: a fully *bundled* design, and a *semi-bundled* one that keeps the
order, algebra, and normed data as separate parameters.

:::table +header
*
  * Bundled
  * Semi-bundled
*
  * `[LinearOrderedCommMonoid α]`
  * `[CommMonoid α] [LinearOrder α] [IsOrderedMonoid α]`
*
  * `[OrderedCommGroup α]`
  * `[CommGroup α] [PartialOrder α] [IsOrderedMonoid α]`
*
  * `[OrderedSemiring α]`
  * `[Semiring α] [PartialOrder α] [IsOrderedRing α]`
*
  * `[OrderedRing α]`
  * `[Ring α] [PartialOrder α] [IsOrderedRing α]`
*
  * `[LinearOrderedField α]`
  * `[Field α] [LinearOrder α] [IsStrictOrderedRing α]`
*
  * `[NormedLatticeAddCommGroup α]`
  * `[NormedAddCommGroup α] [Lattice α] [HasSolidNorm α] [IsOrderedAddMonoid α]`
*
  * `[NormedLinearOrderedField α]`
  * `[NormedField α] [LinearOrder α] [IsStrictOrderedRing α]`
:::

# Partitioning the Search Space
%%%
tag := "optimising-partition"
%%%

The semi-bundled refactor partitioned the instance search space. When trying to
synthesize a {lean}`CommMonoid` instance under the old design, Lean would search
through declarations like `NormedLinearOrderedField` or `NormedOrderedGroup`. Now
it only goes as far as {lean}`NormedField` and {lean}`Group`.

This decoupling yielded a 20 percent speed-up for typeclass inference and an
overall 6 percent speed-up for Mathlib. The trade-off is more verbose parameter
lists, which raises a genuine design question: should the normed hierarchy be
decoupled from the algebraic hierarchy, and more generally, when should one use a
bundled or an unbundled typeclass design?
