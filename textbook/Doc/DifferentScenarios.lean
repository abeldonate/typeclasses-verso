import VersoManual
import Doc.Meta.Lean

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean


open Doc

set_option pp.rawOnError true



#doc (Manual) "Different scenarios" =>

Sometimes it is not entirely clear whether to use a class or a proposition to encode a particular piece of data. In this section, we will discuss some common scenarios and how to approach them.

The idea behind this choice is:

- Choose `class` when you expect inference to fill it in automatically, especially if many definitions and theorems should work uniformly once an instance is available.
- Choose `Prop` when the fact is local, passed explicitly, or when multiple distinct witnesses should remain visible and not be merged by typeclass search.

We see the difference in the syntax here:
```lean
class MyClass (α : Type u) where
  field1 : α → α
  field2 : α
  myaxiom : ∀ x, field1 (field1 x) = field1 x

def MyProp (α : Type u) : Prop :=
  ∃ (field1 : α → α) (field2 : α),
    ∀ x, field1 (field1 x) = field1 x
```

In practice:

- A class is resolved by typeclass search `[MyClass α]` and is convenient when you want implicit arguments.
- A proposition is provided directly as a term `(h : MyProp α)` and is convenient when assumptions are explicit and local.

# Algebraic structures

The most common example-rich scenario is algebraic structures. They are organized in hierarchies (`Semigroup`, `Monoid`, `Group`, `Ring`, ...) and are almost always encoded as classes.

This gives two major benefits:

- Inheritance: a `Ring` instance can extend many parent structures and reuse their fields and lemmas.
- Inference: once `[Ring α]` is available, notation and lemmas that require additive or multiplicative structure work immediately.

If the same structure were passed as a large explicit proposition every time, terms would become verbose and less compositional.

Some examples include:
```lean
class Group2 (α : Type u) extends Monoid α where
  inv : α → α
  -- axioms omitted

example : Group ℤ := by infer_instance


# Injective (Prop) / Mono (Class)

In mathlib, the class-oriented name is usually `Mono`
(in category theory), not `Injective`.

For this section, we keep a function-level comparison:

- `MonoP` as an explicit proposition.
- `MonoC` as a class carrying the same cancellation law.

```lean
variable {α β γ δ : Type u}

def MonoP (f : α → β) : Prop :=
  ∀ ⦃x y : α⦄, f x = f y → x = y

class MonoC (f : α → β) : Prop where
  cancel : ∀ ⦃x y : α⦄, f x = f y → x = y
```

For each of these, we can prove that composition preserves the property:
```lean
theorem compositionP
    (f : α → β) (g : β → γ) (h₁ : MonoP f) (h₂ : MonoP g) :
    MonoP (g ∘ f) := by
  intro x y h
  apply h₁
  apply h₂
  simpa [Function.comp] using h

instance monoComp
    (f : α → β) (g : β → γ)
    [MonoC f] [MonoC g] :
    MonoC (g ∘ f) where
  cancel := by
    intro x y h
    apply MonoC.cancel (f := f)
    apply MonoC.cancel (f := g)
    simpa [Function.comp] using h
```

But there is a key difference in how these are used:
```lean
example (f : α → β) (g : β → γ) (h₁ : MonoP f) (h₂ : MonoP g) :
    MonoP (g ∘ f) := by
  apply compositionP f g h₁ h₂

example (f : α → β) (g : β → γ) [MonoC f] [MonoC g] :
    MonoC (g ∘ f) := by
  infer_instance

-- If we want a more elaborate example
example (f : α → β) (g : β → γ) (h : γ → δ) [MonoC f] [MonoC g] [MonoC h] :
    MonoC (h ∘ g ∘ f) := by
  infer_instance
```


Rule of thumb:

- Use a proposition (`MonoP`) for local assumptions.
- Use a class (`MonoC`) for reusable inferred structure.

# More classes
- From relations
  - Preorder, PartialOrder, LinearOrder, Lattice
- From category
  - Category, Functor, NaturalTransformation, Mono, Epi, Iso
- From sets
  - Subset, Disjoint, Finite, Infinite
- From other structures
  - Topological spaces, Metric spaces, Measurable spaces, etc.
