/-
Copyright (c) 2024-2025 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: David Thrane Christiansen
-/

import VersoManual
import Doc.Papers

import Doc.WhyTypeClasses
import Doc.DifferentScenarios
import Doc.TableTypeclassResolution

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean


set_option pp.rawOnError true


#doc (Manual) "A verso documentation for a talk in type classes" =>

%%%
authors := ["Alex Brodbelt, Abel Donate"]
%%%

{include 1 Doc.WhyTypeClasses}
{include 1 Doc.DifferentScenarios}
{include 1 Doc.TableTypeclassResolution}
