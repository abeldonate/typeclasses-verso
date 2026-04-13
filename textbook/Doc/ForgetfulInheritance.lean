import VersoManual
import Doc.Meta.Lean
import Mathlib.Algebra.Group.Basic

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean


open Doc

set_option pp.rawOnError true



#doc (Manual) "Forgetful Inheritance" =>

Forgetful inheritance means that when a class extends a parent class, any instance of
the child can be used as an instance of the parent.

In this running example, every `Group α` should also be usable as a `Monoid α`.

```lean
namespace MyAlgebra
class Monoid (α : Type u) where
  mul : α → α → α
  one : α
  -- axioms omitted

class Group (α : Type u) extends Monoid α where
  inv : α → α
  -- axioms omitted
end MyAlgebra
```

In both Lean 3 and Lean 4, `extends` records the parent fields and also provides the
forgetful step needed by typeclass search.

That is, if Lean is trying to solve `[MyAlgebra.Monoid α]` and it already has
`[MyAlgebra.Group α]`, it can project the parent structure automatically.

Lean 3 and Lean 4 are very similar here. The main practical differences are surface
syntax and tooling, not the core idea.

Conceptually, this is why the pattern is called forgetful inheritance:

1. `Group α` contains strictly more structure than `Monoid α`.
2. Instance search can forget the extra part (`inv`) when only monoid data is needed.
3. This keeps hierarchies modular while avoiding duplicate instance declarations.

When porting from Lean 3 to Lean 4, code that relies on this behavior usually ports
directly. Most changes happen around parser differences and updated elaboration details,
not around inheritance itself.
