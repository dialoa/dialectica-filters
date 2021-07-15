
---
title: "Recursive-citeproc - Self-citing Pandoc citeproc bibliographies"
author: "Julien Dutant"
---

Recursive-citerpoc
==============

Self-citing Pandoc citeproc bibliographies. 

v0.1. Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>. Based on an idea by John MacFarlane.
License:  MIT - see LICENSE file for details.

Introduction
------------

BibTeX bibliography files can self-cite: one bibliography entry
may include a citation of another entry in the same bibliography.
Pandoc's `citeproc` doesn't handle such citations properly. This
filters handles them. 

Usage
-----

Add `recursive-citeproc.lua` to your document's list of filters, or pass it to the command line with the argument `-L`. The file `recursive-citeproc.lua` should be in PATH. 

The filter should be placed:
* after any filter that adds to the document citations,
* but before any filter that changes the document's body
* before `citeproc`

Advanced usage
-------------------  

