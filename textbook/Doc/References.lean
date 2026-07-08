/-
Copyright (c) 2026 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import VersoManual
import Doc.Meta.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open Doc

set_option pp.rawOnError true
set_option verso.code.warnLineLength 0

#doc (Manual) "References" =>
%%%
tag := "references"
number := false
%%%

* Anne Baanen et al. *Growing Mathlib: maintenance of a large scale mathematical
  library*.
* Anne Baanen. *Use and Abuse of Instance Parameters in the Lean Mathematical
  Library*.
* Eric Wieser. *Multiple-Inheritance Hazards in Dependently-Typed Algebraic
  Hierarchies*.
