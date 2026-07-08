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

#doc (Manual) "Instance Priorities" =>
%%%
tag := "priorities"
shortTitle := "Priorities"
%%%

Many hierarchies present diamonds.

![Algebraic hierarchy](../figures/HierarchyAlgebra.png)

Diamonds are not always bad, but there are performance considerations to keep in
mind.

# A Toy Diamond
%%%
tag := "priorities-toy-diamond"
%%%

Consider the toy example below.

![A single diamond](../figures/SingleDiamond.svg)

In code, this corresponds to a {deftech}_diamond_ of classes:

```lean
namespace Doc.PrioritiesDemo

set_option linter.unusedVariables false

class Base (B : Type u) where
  base : String

class LeftBranch (B : Type u) extends Base B
class RightBranch (B : Type u) extends Base B

class Diamond (B : Type u) extends LeftBranch B, RightBranch B

inductive D

instance : Diamond D where base := "base"

set_option trace.Meta.synthInstance true in
#synth Base D

instance (priority := high) {α : Type u} [LeftBranch α] : Base α := inferInstance

set_option trace.Meta.synthInstance true in
#synth Base D

end Doc.PrioritiesDemo
```

Priorities tell the instance synthesis algorithm to consider certain instances
before others.

# Priorities in Mathlib
%%%
tag := "priorities-mathlib"
%%%

The toy example is not too interesting, but the mechanism is exactly what Mathlib
relies on. Consider this definition found in Mathlib:

```
def RestrictScalars.lsmul [Module S M] : S →ₐ[R] Module.End R (RestrictScalars R S M) :=
  -- We use `RestrictScalars.moduleOrig` in the implementation, but not in the type
  letI : Module S (RestrictScalars R S M) := RestrictScalars.moduleOrig R S M
  Algebra.lsmul R R (RestrictScalars R S M)
```

When we peek into the synthesis trace, we keep seeing `Algebra.id`. This is not by
chance: a `Loogle` search shows there are *many* instances of the form
`Algebra ?R ?S`.

![Algebra instances](../figures/AlgebraInstances.png)

As anticipated, `Algebra.id` is given a high priority. Why? If it is going to
fail, it generally fails fast; and if it succeeds, it is almost surely the
instance we wanted.

Dually, we can set *low* priorities for instances that are unlikely to succeed.
When searching for algebraic instances we rarely need the normed hierarchy, so
Mathlib pushes it to the end:

```
attribute [instance 200] ESeminormedAddMonoid.toAddMonoid
```

In summary:

* Set *high* priorities for instances that are cheap to fail and are usually the
  desired one, as with `Algebra.id`.
* Set *low* priorities for instances that are less likely to apply, as with
  `ESeminormedAddMonoid.toAddMonoid`.

There are rumours that the typeclass system will be redesigned in a way that
renders manual priority twiddling obsolete.
