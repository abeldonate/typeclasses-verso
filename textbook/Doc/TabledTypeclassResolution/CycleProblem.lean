import VersoManual
import Doc.Meta.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Doc

set_option pp.rawOnError true

#doc (Manual) "The Cycle Problem" =>

The cycle problem appears when instance search comes back to a goal
it is already trying to solve.

With naive depth-first search, this can cause non-termination: the
resolver keeps unfolding one goal into subgoals that eventually
recreate the original goal.

The paper gives two canonical examples.

*Example 1: coercion transitivity.*

```lean
namespace MyCoe
class CoeT (α β : Type) where
  coe : α → β

-- Natural transitivity rule.
def coeTransRule {α β γ : Type} [ab : CoeT α β] [bg : CoeT β γ] :
    CoeT α γ where
  coe x := bg.coe (ab.coe x)
end MyCoe

-- If search tries to build `CoeT α β` using `coeTrans`,
-- it introduces a fresh middle type and subgoals:
--   CoeT α ?m and CoeT ?m β
-- Repeating that step can recreate the same shape forever.
```

*Example 2: restricting module scalars.*

```lean
-- Toy classes matching the shape from the paper.
class ToyRing (A : Type) where
class ToyCommRing (R : Type) extends ToyRing R where
class ToyAddCommGroup (M : Type) where
class ToyModule (A M : Type) [ToyRing A] [ToyAddCommGroup M] where
class ToyAlgebra (R A : Type) [ToyCommRing R] [ToyRing A] where

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
