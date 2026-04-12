import VersoManual
import Doc.Meta.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean
open Doc

set_option pp.rawOnError true

#doc (Manual) "The Cycle Problem" =>

The cycle problem appears when instance search can come back to a
goal it is already trying to solve. This happens naturally in
useful modeling patterns, for example with coercions or
structures that can be inferred through intermediate classes.

With depth-first resolution, these recursive dependencies can
cause non-termination: the resolver keeps unfolding a goal into
subgoals that eventually recreate the original goal.

As a result, users must often avoid natural cyclic relationships
or encode awkward workarounds to prevent loops. This makes class
design less expressive and harder to maintain.
