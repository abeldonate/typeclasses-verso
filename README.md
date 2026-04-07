# Verso Textbook Template

This repository contains a textbook template that can be used to get started with Verso.

To build and view the textbook, run:
```
$ ./generate.sh
$ python3 ./serve.py 8000
```
The page is served at `localhost:8000`.

## Textbook

The textbook example demonstrates how to use a single version of Lean for code examples and the
document's text. In this example, the Lean code blocks elaborate together with the text of the book.

Additionally, this example demonstrates one way to extend the `Manual` genre with new features. It
includes a separate pass for extracting specially-indicated code blocks to their own files, as a
part of building the book. This can be used to create a downloadable archive of the book's example
code, without requiring readers to install or use Verso. This feature is implemented by wrapping the
Lean code block that ships with Verso, so blocks that are to be extracted are indicated as such.
Then, a custom build pass traverses the document, finding all the indicated examples and writing
them to files.

