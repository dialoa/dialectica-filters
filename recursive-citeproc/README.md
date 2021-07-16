
---
title: "Recursive-citeproc - Self-citing Pandoc citeproc bibliographies"
author: "Julien Dutant"
---

Recursive-citerpoc
==============

Self-citing Pandoc citeproc bibliographies. 

v0.1. Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>. 
Based on an idea by John MacFarlane.
License:  MIT - see LICENSE file for details.

Introduction
------------

BibTeX bibliography files can *self-cite*: one bibliography entry
may cite another entry. In many cases this can be achieved 
by adding a `crossref` field (e.g.
when crossreferring the collection or proceedings from which an 
article is extracted, see the [BibTeX's documentation](https://ctan.math.illinois.edu/biblio/bibtex/base/btxdoc.pdf)). 
But in others we use a LaTeX citation command, e.g. as part of
a note that mentions a reprint. Here are examples of both:

```bibtex
@collection{Snow:2000,
    editor = 'Jane Snow',
    title = 'Fishy Works',
}
@incollection{Doe:2000,
    author = 'Jane Doe',
    title = 'What are Fish Even Doing Down There',
    crossref = 'Snow:2000',
}
@book{Snow:2010,
    editor = 'Jane Snow',
    title = 'Fishy Works',
    note = 'Reprint of~\citet{Snow:2000}'
}
```

When used with `natbib` or `biblatex` in LaTeX, self-citations are
processed by compiling the source file several times. 

Pandoc's own bibliography engine, Citeproc, handles self-citations
with the `crossref` field but not those made with LaTeX 
citation commands. This filter allows Citeproc to handle them too.

Two remarks. First, self-citing bibliographies are perhaps a 
bad idea. They have a few advantages though: minimizing the updates
needed, ensuring consistency, flexibility of outputs style (e.g
self-citing numerically or in author-date). Not to mention the
fact that some of us just have these large self-citing databases already.
Second, Pandoc can of course use `natbib`/`biblatex` too. But to 
produce other outputs than LaTeX/PDF and to use 
[CSL|https://citationstyles.org/] style files Citeproc is the way
to go.

Usage
-----

Add `recursive-citeproc.lua` to your document's list of filters, or pass it to the command line with the argument `-L`. The file `recursive-citeproc.lua` should be in PATH. 

The filter should be placed:
* after any filter that adds to the document citations,
* but before any filter that changes the document's body
* before `citeproc`

What the filter does and interaction with other filters
-------------------  

