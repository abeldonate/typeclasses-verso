/-
Copyright (c) 2026 Lean FRO LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import VersoManual
import Doc.Meta.Lean

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean

open Doc

set_option pp.rawOnError true
-- Disable the "line too long" warning for code blocks in this reference chapter.
set_option verso.code.warnLineLength 0

/-!
This chapter is a self-contained tour of the markup you can use when authoring a
Verso *manual* (the `#doc (Manual)` genre used by this textbook). Every feature
below is demonstrated with real, compiling markup so you can copy it directly.
-/

#doc (Manual) "A Tour of Verso Manual Features" =>
%%%
tag := "verso-features"
shortTitle := "Verso Features"
%%%

This chapter demonstrates, in one place, the features available when writing a
Verso document in the {name}`Manual` genre. Each section is both an explanation
*and* a live example: what you read is produced by the very markup it describes.

The title metadata above is written in a `%%%` block placed immediately after
the header. The `tag` field gives the part a stable anchor for permalinks and
cross-references, while `shortTitle` supplies a shorter name for navigation
menus. Metadata blocks contain Lean structure-initializer syntax, so they cannot
contain comments.

# Document Structure
%%%
tag := "features-structure"
%%%

A document is a tree of {deftech}_parts_ (chapters, sections, subsections). A
part is introduced by a {deftech}_header_ — one or more `#` characters at the
start of a line. The number of `#` marks the nesting depth: the top-level header
always uses a single `#`, and each level may add at most one `#`.

## A Subsection
%%%
tag := "features-subsection"
%%%

This is a subsection (`##`). Metadata is attached to a header with a `%%%` block
placed immediately after it. Useful fields include `tag`, `shortTitle`,
`number := false` (to suppress numbering), and `htmlSplit`.

### A Sub-subsection

Headers keep nesting with more `#` characters.

# Inline Markup
%%%
tag := "features-inline"
%%%

Text can be _emphasized_ with underscores and made *bold* with asterisks. You
can __nest _emphasis_ inside__ stronger emphasis by using more delimiters.
Literal code is written in backticks: `fun x => x + 1`.

Hyperlinks come in two forms. Inline links put the target in parentheses, like
[the Lean website](https://lean-lang.org). Named links refer to a target defined
elsewhere, like [the Verso repository][verso-repo], which keeps long URLs out of
the prose.

[verso-repo]: https://github.com/leanprover/verso

You can also attach footnotes to text.[^note] Footnote definitions live in their
own block and may appear anywhere in the document.

[^note]: This is a footnote. Its marker is `[^note]` and its definition begins
with `[^note]:`.

# Lists
%%%
tag := "features-lists"
%%%

There are three kinds of lists. First, unordered lists:

* Bullets start with `*`, `-`, or `+`.
* Items may contain multiple paragraphs and nested lists:
  * A nested bullet, indented under its parent.
  * Another nested bullet.

Second, ordered lists:

1. The first step.
2. The second step.
3. The third step.

Third, description lists, which pair a term with its explanation:

: {deftech}_Role_

  An inline extension, written `{name}[...]`, that gives special meaning to the
  inlines it wraps.

: {deftech}_Directive_

  A block extension, written with `:::name`, that wraps a sequence of blocks.

# Quotations
%%%
tag := "features-quotes"
%%%

A line beginning with `>` starts a block quotation:

> Mathematics is the art of giving the same name to different things.
>
> This second paragraph is still part of the quotation.

# Mathematics
%%%
tag := "features-math"
%%%

Inline math uses a single dollar sign followed by backticked TeX, such as
$`e^{i\pi} + 1 = 0`. Display math uses two dollar signs and is centered on its
own line:

$$`\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}`

# Code Blocks
%%%
tag := "features-code"
%%%

A plain code block (no language after the fence) is rendered verbatim:

```
This text is shown exactly as written,
with    all    spacing    preserved.
```

A `lean` code block is elaborated in the document's Lean environment, so it is
type-checked and gets full syntax highlighting and hovers:

```lean
def featureDemoDouble (n : Nat) : Nat := n + n

theorem featureDemoDouble_eq (n : Nat) : featureDemoDouble n = 2 * n := by
  simp [featureDemoDouble, Nat.two_mul]
```

Definitions from earlier `lean` blocks stay in scope in later ones:

```lean
#check featureDemoDouble
```

To capture and display the output of a command, name the block and reference the
name from a `leanOutput` block:

```lean (name := evalDemo)
#eval List.range 5
```
```leanOutput evalDemo
[0, 1, 2, 3, 4]
```

Use the `+error` flag to assert that a block *must* produce an error (the error
is then shown as expected output rather than failing the build):

```lean +error
example : 1 + 1 = 3 := rfl
```

Use the `-show` flag to elaborate setup code without displaying it. The
following hidden block defines `featureSecret`, which the next visible block can use:

```lean -show
def featureSecret : String := "hidden setup"
```
```lean
#eval featureSecret
```

Non-Lean languages are shown with highlighting appropriate to a verbatim block:

```
$ lake build
Build completed successfully.
```

# Inline Lean Roles
%%%
tag := "features-lean-roles"
%%%

Several roles elaborate Lean fragments inside prose:

* {name}`lean` elaborates a term: {lean}`2 + 2` or {lean}`fun (n : Nat) => n + 1`.
* {name}`name` links to a declaration by its name: {name}`List.map` and
  {name}`Nat.succ`.
* {name}`option` documents a compiler option inline: {option}`pp.all`.

# Roles for Prose
%%%
tag := "features-prose-roles"
%%%

The {name}`deftech`/{name}`tech` pair manages a glossary of technical terms. At
the definition site you write `{deftech}_forgetful inheritance_` to introduce a
{deftech}_forgetful inheritance_ term; elsewhere `{tech}[forgetful inheritance]`
produces a link back to it, like this reference to {tech}[forgetful inheritance].

The {name}`margin` role attaches a marginal note to the
text.{margin}[Marginal notes are great for asides that would otherwise interrupt
the flow of a sentence.]

Cross-references use the {name}`ref` role together with a `tag`. For example,
{ref "features-code"}[the section on code blocks] links to it by its tag, and
{ref "features-lists"}[the section on lists] links to another. Because these use
tags rather than titles, the links survive reorganizing the document.

# Directives
%%%
tag := "features-directives"
%%%

A {tech}[directive] is a block wrapper introduced by three or more colons. The
{name}`paragraph` directive groups several blocks — including lists, which
normally cannot appear inside a paragraph — into one logical paragraph:

:::paragraph
The following options are supported, and this list is part of the surrounding
logical paragraph:

* the first option,
* the second option.

This closing sentence is also part of the same logical paragraph.
:::

The {name}`table` directive builds a table from a list of rows, where each row is
itself a list of cells. The `+header` flag treats the first row as column
headers:

:::table +header
*
  * Markup
  * Meaning
*
  * `_x_`
  * emphasized text
*
  * `*x*`
  * bold text
*
  * `` `x` ``
  * literal code
:::

# Documentation Directives
%%%
tag := "features-docs"
%%%

Verso can render Lean's own documentation. The {name}`docstring` command inserts
the docstring and signature of a declaration:

{docstring List.forM}

The {name}`optionDocs` command renders the documentation of a compiler option:

{optionDocs pp.deepTerms.threshold}

The {name}`tactic` directive renders a tactic's documentation:

:::tactic "simp"
:::

# Grouping and Sections
%%%
tag := "features-sections"
%%%

The {name}`leanSection` directive opens a Lean `section` around its contents, so
`variable` declarations and `open` commands are scoped to just that region:

:::leanSection
```lean -show
variable {α : Type}
namespace FeatureDemo
```
```lean
def featureIdentity (x : α) : α := x
end FeatureDemo
```
:::

Outside the section, the `α` variable is no longer in scope, keeping the rest of
the document clean.
