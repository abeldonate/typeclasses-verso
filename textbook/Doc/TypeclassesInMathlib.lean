import VersoManual
import Doc.Meta.Lean

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean

open Doc

set_option pp.rawOnError true

#doc (Manual) "Typeclasses in Mathlib" =>

As we have seen typeclasses provide a very expressive way to define mathematical structures
and common specifications that a type might satisfy. However, it is this flexibility also presents drawbacks
that lead to considerations when having to design Mathlib.

--Example of two different ways to formalise groups, which definition to pick? what are the considerations?

For a moment, let us take a step back and recall that one of the objectives of Mathlib is to present a *unified* digital library
_convenient_ for formalising current research in mathematics. Concretely, we would like Mathlib to be the backbone for downstream research projects like the formalisation of a modern proof
of Fermat's Last Theorem or Carleson's theorem on the convergence of Fourier series. Given the complexity of the arguments there are technical considerations
to explore during the formalisation:

--Example within these projects of problems encountered with instance synthesis being too slow, or there being a lot of duplication.

One way to make Mathlib convenient is through the use of typeclasses (examples: Theorem statements, Fact, Coercions, etc.)
- The library to compile reasonably quickly. _unbundling_ vs _bundling_ in the algebraic and order hierarchies
- To avoid code duplication and thus would like definitions and typeclasses to be reasonably general and well-integrated, we want avoid reproving similar
  looking statements to reduce the maintenance. `SetLike`, `FunLike`, `EquivLike`, `RCLike`

Considering that instance synthesis corresponds to around 20% of Mathlib build time, we want instance synthesis to be fast.
This means we want instance synthesis to fail fast and we don't want the space of instances to grow too large

--Example of slow synthesis

--Example of large search space
