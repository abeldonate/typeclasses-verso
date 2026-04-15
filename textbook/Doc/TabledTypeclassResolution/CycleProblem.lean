import VersoManual
import Doc.Meta.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Doc

set_option pp.rawOnError true
set_option verso.code.warnLineLength 0

#doc (Manual) "The Cycle Problem" =>

The cycle problem appears when instance search comes back to a goal
it is already trying to solve.

With naive depth-first search, this can cause non-termination: the
resolver keeps unfolding one goal into subgoals that eventually
recreate the original goal.

The paper gives two canonical examples.

*Example 1: coercion transitivity.*

```lean
class MyCoeT (α β : Type) where
  coe : α → β

-- Natural transitivity rule.
def coeTransRule {α β γ : Type} [ab : MyCoeT α β] [bg : MyCoeT β γ] :
    MyCoeT α γ where
  coe x := bg.coe (ab.coe x)
```

Suppose the resolver is trying to build:

`MyCoeT α β`

and it repeatedly chooses the transitivity rule.
The search unfolds like this:

`MyCoeT α β`
`→` choose `coeTransRule` with a fresh middle type `?m₁`
`→` subgoals: `MyCoeT α ?m₁` and `MyCoeT ?m₁ β`
`→` again choose `coeTransRule` for `MyCoeT α ?m₁`,
`→` introducing `?m₂`
`→` new subgoals include `MyCoeT α ?m₂` and `MyCoeT ?m₂ ?m₁`
`→` again choose `coeTransRule` for `MyCoeT α ?m₂`,
`→` introducing `?m₃`
`→` new subgoals include `MyCoeT α ?m₃` and `MyCoeT ?m₃ ?m₂`
`→` ...

This is the loop the processor keeps repeating
in naive depth-first search.

![Trivial loop in coercion transitivity](../figures/CoeTransitive.svg)

*Example 2: restricting module scalars.*

```lean
-- Toy classes matching the shape from the paper.
class ToyRing (A : Type) where
  -- ...
class ToyCommRing (R : Type) extends ToyRing R where
  -- ...
class ToyAddCommGroup (M : Type) where
  -- ...
class ToyModule (A M : Type) [ToyRing A] [ToyAddCommGroup M] where
  -- ...
class ToyAlgebra (R A : Type) [ToyCommRing R] [ToyRing A] where
  -- ...

-- Restrict scalars:
-- if M is an A-module and A is a k-algebra,
-- then M is also a k-module.
def restrictScalarsRule {k A M : Type}
    [ToyCommRing k] [ToyRing A] [ToyAddCommGroup M]
    [ToyAlgebra k A] [ToyModule A M] : ToyModule k M :=
  {}

-- Every commutative ring is an algebra over itself.
def selfAlgebraRule
    (A : Type)
    [ToyCommRing A] :
    ToyAlgebra A A :=
  {}

-- The combination of these rules is useful,
-- but can create cycles
-- for search procedures that do not table subgoals.
```

In both examples, tabling breaks the loop by remembering subgoals and
reusing in-progress/known results instead of expanding forever.
