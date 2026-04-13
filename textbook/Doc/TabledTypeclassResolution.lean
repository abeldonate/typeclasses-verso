import VersoManual
import Doc.Meta.Lean
import Doc.TabledTypeclassResolution.DiamondProblem
import Doc.TabledTypeclassResolution.CycleProblem
import Doc.TabledTypeclassResolution.TabledResolution

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean


open Doc

set_option pp.rawOnError true



#doc (Manual) "Table Typeclass Resolution" =>

*Problems with the former implementation*

Before tabled typeclass resolution, Lean followed a search strategy that is close to
standard SLD-style backtracking. This older approach is simple and effective on small
instance graphs, but it scales poorly in the kinds of hierarchies used in formal
mathematics.

The paper highlights two core limitations of that former implementation:
_The diamond problem_

The diamond problem appears when there are multiple inheritance paths from one class
to another. In algebraic hierarchies, this is common: one structure may inherit
different parents that both eventually provide the same target capability.

When resolution explores these paths naively, it repeatedly recomputes essentially the
same subgoals. In towers of diamonds, the number of paths grows exponentially with
depth, so failing searches (or searches whose later goals fail) can trigger a large
amount of duplicated work.

In practice, this leads to severe slowdowns in large libraries. Queries that look
harmless can become unexpectedly expensive because the resolver must enumerate many
equivalent routes through the instance graph.

_The cycle problem_

The cycle problem appears when instance search can come back to a goal it is already
trying to solve. This happens naturally in useful modeling patterns, for example with
coercions or structures that can be inferred through intermediate classes.

With the former depth-first resolution strategy, these recursive dependencies can cause
non-termination: the resolver keeps unfolding a goal into subgoals that eventually
recreate the original goal.

As a result, users must often avoid natural cyclic relationships or encode awkward
workarounds to prevent loops. This makes class design less expressive and harder to
maintain.

Together, diamonds and cycles explain why the former implementation was a bottleneck
for scaling typeclass-heavy developments, and why a tabled approach is needed.


{include 1 Doc.TabledTypeclassResolution.DiamondProblem}
{include 1 Doc.TabledTypeclassResolution.CycleProblem}
{include 1 Doc.TabledTypeclassResolution.TabledResolution}
