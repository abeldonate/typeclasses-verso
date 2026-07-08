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

#doc (Manual) "Coercions" =>

--To motivate FunLike, EquivLike we exemplify how many theorems pertaining to homomorphisms, isomorphisms within certain categories are required (similar vein to Filters)

--OutParam

--Motivate RCLike
