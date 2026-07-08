/-
Copyright (c) 2024-2025 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: David Thrane Christiansen
-/

import VersoManual
import Doc.Papers

import Doc.MathlibMission
import Doc.WhyTypeClasses
import Doc.DifferentScenarios
import Doc.TypeclassUse
import Doc.OptimisingSynthesis
import Doc.Priorities
import Doc.ForgetfulInheritance
import Doc.Hazards
import Doc.TypeSynonyms
import Doc.TabledTypeclassResolution
import Doc.SeminarConclusion
import Doc.References
import Doc.VersoFeatures

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

{include 1 Doc.MathlibMission}
{include 1 Doc.WhyTypeClasses}
{include 1 Doc.DifferentScenarios}
{include 1 Doc.TypeclassUse}
{include 1 Doc.OptimisingSynthesis}
{include 1 Doc.Priorities}
{include 1 Doc.ForgetfulInheritance}
{include 1 Doc.Hazards}
{include 1 Doc.TypeSynonyms}
{include 1 Doc.TabledTypeclassResolution}
{include 1 Doc.SeminarConclusion}
{include 1 Doc.References}
{include 1 Doc.VersoFeatures}
