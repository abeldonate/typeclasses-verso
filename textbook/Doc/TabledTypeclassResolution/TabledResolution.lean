import VersoManual
import Doc.Meta.Lean
import Mathlib.Algebra.Group.Basic

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Doc

set_option pp.rawOnError true

#doc (Manual) "Tabled Typeclass Resolution" =>

Tabled typeclass resolution is the key idea in the paper: instead of treating
instance search as pure tree search, Lean stores intermediate goals in a
table and reuses results.

The table is conceptually indexed by subgoals such as `Monoid α` or
`Group α`, and each entry records:

1. whether the goal is currently being explored,
2. which candidate instances have already been tried,
3. which solutions have been found.

This changes search from "recompute everything along each path" into
"compute once, then share".

*What this solves from the paper.*

1. Diamonds stop causing exponential recomputation, because equivalent
subgoals are looked up in the same table entry.
2. Cycles stop diverging (under the bounded term-size assumption), because
encountering an in-progress goal does not recursively unfold forever.

In short, tabling turns repeated backtracking over a search tree into
goal-directed exploration over a graph of shared subproblems.

*Concrete worked example: `CommGroup α` to `Monoid α`.*

In mathlib's hierarchy, `Monoid α` can be obtained from `CommGroup α`
through two paths:

1. `CommGroup α -> Group α -> DivInvMonoid α -> Monoid α`
2. `CommGroup α -> CommMonoid α -> Monoid α`

So, when solving a bigger query that depends on `Monoid α`, the resolver
sees a diamond.

```lean
variable {α : Type}

-- Relevant classes from the hierarchy.
#check CommGroup α
#check Group α
#check DivInvMonoid α
#check CommMonoid α
#check Monoid α
```

We can make both branches explicit in Lean:

```lean
variable {α : Type}

def monoidViaGroup [Group α] : Monoid α := inferInstance
def monoidViaCommMonoid
    [CommMonoid α] : Monoid α :=
  inferInstance

example [CommGroup α] : Monoid α := monoidViaGroup
example [CommGroup α] : Monoid α := monoidViaCommMonoid
```

The two `example`s above intentionally use different intermediate classes,
but end at the same goal `Monoid α`.

Suppose the current goal requires `[Monoid α]` and `[CommGroup α]` is already
available in context.

Detailed search sketch (same logical goal, two derivation routes):

1. Start with goal `Monoid α`.
2. Resolver tries a rule reducing it to `Group α` (or some branch that needs
`Group α`).
3. To solve `Group α`, it uses `[CommGroup α]` from context.
4. From `Group α`, it obtains `DivInvMonoid α`, then `Monoid α`.
5. In another branch, resolver may instead reduce via `CommMonoid α`.
6. Again it uses `[CommGroup α]` to get `CommMonoid α`, then `Monoid α`.

Both branches prove the same target class, so they are duplicated work unless
the resolver shares results.

Naive backtracking behavior:

1. Try the `Group` route, derive `Monoid α`.
2. Later branch fails for unrelated reasons.
3. Backtrack and try the `CommMonoid` route, deriving `Monoid α` again.
4. In a tower of repeated diamonds, this duplicated work compounds
exponentially.

Tabled behavior:

1. Open table entry for goal `Monoid α`.
2. Explore one route (say via `Group`) and store the discovered solution.
3. Any later request for `Monoid α` reuses the stored result immediately.
4. If another route is needed, it extends the same entry instead of creating
an independent copy of the search.

We can also force repeated requests of the same class in one term:

```lean
variable {α : Type}

def needsTwoMonoids
    [Monoid α] : Monoid α × Monoid α :=
  (inferInstance, inferInstance)

example [CommGroup α] : Monoid α × Monoid α :=
  needsTwoMonoids
```

Conceptually, both components of `needsTwoMonoids` ask for the same subgoal
`Monoid α`. Tabled search treats this as one shared table entry.

The crucial point is that `Monoid α` is treated as one shared subproblem, not
as many independent tree nodes.

*Mini intuition for complexity.*

If each level introduces one diamond, naive search may revisit equivalent
goals along roughly $2^n$ path combinations at depth $n$, while tabling keeps
the number of distinct goal states close to the number of unique subgoals.
This is the source of the exponential speedups reported in the paper.
