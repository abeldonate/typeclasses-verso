import VersoManual
import Doc.Meta.Lean
import Mathlib.Order.Lattice

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean


open Doc

set_option pp.rawOnError true
set_option verso.code.warnLineLength 0



#doc (Manual) "Why Type Classes?" =>

Type classes enable _ad-hoc polymorphism_: the same operation name can have different behaviors depending on the type. Here we demonstrate this with a custom `myAdd` class that adapts the notion of "addition" to different types.

*Define an Interface (The Polymorphic Contract)*

```lean
class myAdd (α : Type) where
  add : α → α → α
```

This declares that for any type `α`, if `α` has a `myAdd` instance, then `α` knows how to add two `α` values. Code using `myAdd` does not need to know which `α` it is—that is polymorphism.

*Provide Different Implementations for Different Types*

```lean
instance : myAdd Nat where
  add := Nat.add

instance : myAdd Bool where
  add := Bool.or

instance : myAdd Float where
  add := fun x y => x*y
```

Here, `Nat` uses arithmetic addition, `Bool` uses logical OR, and `Float` uses multiplication (intentionally unusual to show flexibility). Same function name `add`, different meanings per type. This is ad-hoc polymorphism.

*Use the Same Call on Different Types*

```lean
#eval myAdd.add 1 2
#eval myAdd.add false false
#eval myAdd.add 2.5 4.5
```

Lean infers which instance to use from the argument types. For `Nat` it picks `Nat.add`, for `Bool` it picks `Bool.or`, and for `Float` it picks the multiplication implementation.

*Write Generic Functions That Work for All Instances*

```lean
def double [myAdd α] (x : α) : α :=
  myAdd.add x x

#eval double 3.3
```

`double` is parametric over `α` with a type-class constraint `[myAdd α]`. It works for _any_ `α` that has a `myAdd` instance—one function, many concrete behaviors.

*Lift Polymorphism to Container Types*

```lean
instance [myAdd α] : myAdd (Array α) where
  add x y := Array.zipWith myAdd.add x y

#eval myAdd.add #[1, 2] #[3, 4]
```

If elements of type `α` can be added, then arrays of `α` can be added pointwise. This is _instance composition_: building new polymorphic behavior from existing instances.

*Provide Named Alternative Instances*

```lean
instance latticeMyAdd [Lattice α] : myAdd α where
  add := fun x y => x ⊔ y

example : Lattice Nat := by infer_instance

#eval myAdd.add 3 4
#eval @myAdd.add Nat latticeMyAdd 3 4
```

In lattices, `add` is reinterpreted as join (`⊔`). The named instance `latticeMyAdd` lets you explicitly select that behavior. With `@myAdd.add Nat latticeMyAdd 3 4`, you bypass default instance search and choose the instance directly.

*Local Override of Instance Resolution*

```lean
#eval (let _ : myAdd Nat := latticeMyAdd; myAdd.add 3 7)
```

Inside this scope, Lean uses `latticeMyAdd` for `Nat`. This demonstrates controlled, local polymorphic behavior changes without touching global instances.

*Understanding the Mechanism*

```lean
#check myAdd.add
#check @myAdd.add
```

The first shows `myAdd.add` with implicit arguments hidden. The second exposes all arguments explicitly, including the instance dictionary. Type-class polymorphism is implemented by passing an instance value under the hood.
