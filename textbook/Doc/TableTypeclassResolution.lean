import VersoManual
import Doc.Meta.Lean

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean


open Doc

set_option pp.rawOnError true



#doc (Manual) "Table Typeclass Resolution" =>
