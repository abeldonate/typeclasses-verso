import VersoManual
import Doc.Meta.Lean
import Mathlib

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Doc

set_option pp.rawOnError true

#doc (Manual) "The Diamond Problem" =>

*The problem*

If we try to infer a lower class from a higher class in this tree, we have (exponentially) many paths to explore.
Even if all paths lead to the same result, the resolver must backtrack and re-explore them when a query fails downstream.

![Hierarchy tree of some algebraic structures](../figures/HierarchyAlgebra.png)

*A simple diamond hierarchy.*

![A simple diamond hierarchy](../figures/SingleDiamond.svg)

```lean
-- Base class
class Base where
  base : String

-- Left branch extends Base
class LeftBranch where
  [b : Base]
  left : String

-- Right branch extends Base
class RightBranch where
  [b : Base]
  right : String

-- Diamond: extends both left and right branches
class Diamond where
  [l : LeftBranch]
  [r : RightBranch]
  diamond : String
```

*Why this creates a diamond problem.*

When we query for a `Diamond` instance, the resolver must:
1. Find a `LeftBranch` instance (which requires `Base`)
2. Find a `RightBranch` instance (which requires `Base`)
3. The `Base` instance is now required from *two different paths*

With naive SLD resolution, when a query fails downstream (e.g., if we need
a `Base` instance that satisfies additional constraints), the resolver
backtracks and tries alternative `Base` instances from both paths independently.

In a tower of diamonds (repeated diamond patterns), this explodes exponentially.

*Concrete example instances.*

```lean
instance baseInst : Base where
  base := "base"

instance leftInst : LeftBranch where
  b := baseInst
  left := "left"

instance rightInst : RightBranch where
  b := baseInst
  right := "right"

instance diamondInst : Diamond where
  l := leftInst
  r := rightInst
  diamond := "diamond"

example : Diamond := diamondInst
```

*Real case in mathlib.*

From `[CommGroup α]`, Lean can obtain `[Monoid α]` by two routes:

- `CommGroup α -> Group α  -> DivInvMonoid α -> Monoid α`
- `CommGroup α -> CommMonoid α -> Monoid α`

Both paths produce the same target class, but naive backtracking can
revisit equivalent subgoals many times in larger hierarchies.

This kind of shared ancestry is very common in mathlib's algebraic
hierarchy, which is why avoiding repeated work is crucial.

```lean
variable {α : Type}

#check CommGroup α
#check Group α
#check CommMonoid α
#check Monoid α

namespace MyAlgebra
class CommGroup (G : Type u) extends Group G, CommMonoid G

class Group (G : Type u) extends DivInvMonoid G where
  protected inv_mul_cancel : ∀ a : G, a⁻¹ * a = 1

class DivInvMonoid (G : Type u) extends Monoid G, Inv G, Div G where
  protected div := DivInvMonoid.div'
  protected div_eq_mul_inv : ∀ a b : G, a / b = a * b⁻¹ := by intros; rfl
  protected zpow : ℤ → G → G := zpowRec npowRec
  protected zpow_zero' : ∀ a : G, zpow 0 a = 1 := by intros; rfl
  protected zpow_succ' (n : ℕ) (a : G) : zpow n.succ a = zpow n a * a := by intros; rfl
  protected zpow_neg' (n : ℕ) (a : G) : zpow (Int.negSucc n) a = (zpow n.succ a)⁻¹ := by intros; rfl

class CommMonoid (M : Type u) extends Monoid M, CommSemigroup M

class Monoid (M : Type u) extends Semigroup M, MulOneClass M where
  protected npow : ℕ → M → M := npowRecAuto
  protected npow_zero : ∀ x, npow 0 x = 1 := by intros; rfl
  protected npow_succ : ∀ (n : ℕ) (x), npow (n + 1) x = npow n x * x := by intros; rfl

end MyAlgebra
```

![Hierarchy tree of some algebraic structures](../figures/AlgebraDiamond.svg)
