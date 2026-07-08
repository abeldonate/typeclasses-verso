import VersoManual
import Doc.Meta.Lean
import Mathlib.Algebra.Group.Int.Defs

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean


open Doc

set_option pp.rawOnError true

#doc (Manual) "Bundled Vs Unbundled" =>

An instance which exemplifies the tight integration between different components within Mathlib and how
trade-offs between readability and performance had to be considered when designing and mantaining
the interaction between the algebraic and order hierarchies.

Starting from an example Abel showcased, consider the integers `ℤ`. We can indeed check that they are an additive commutative group

```lean
#synth AddCommGroup Int
```

Which will allows us to peek into the instance declaration

--Show the instance declaration

--Show the natural numbers as commutative semiring

--Example of the Group, Module typeclass to exemplify another algebraic structure with less structure

--Show how the order theoretic properties are different

--Exhibit two ways of defining the algebraic and order theoretic hierarchy (pre [https://github.com/leanprover-community/mathlib4/pull/20676](Zhao Yuyang's refactor))

--Example of bundled vs unbundled in algebraic hierarchy, order hierarchy, morphisms (how relevant are the older papers? Lean 3)
