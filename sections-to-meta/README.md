# Section-to-meta - Lua filter for Pandoc to capture `abstract`, `thanks` and `keywords` sections in the metadata

The pre-render Lua filter for [Pandoc](https://pandoc.org) allows
you to enter some metadata fields as sections at the beginning of
the document. The filter identifies sections with special titles
and moves them to the document's metadata.

v1.1. Copyright: © 2021-23 Philosophie.ch <www.philosophie.ch>. Written by Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

Description
===========

Pandoc markdown provides `thanks`, `abstract`, `keywords` metadata fields. 
This filter allows you to specify them as sections in the
document itself. There are two reasons to do this:

- if your source document is e.g. `docx`, you can enter sections that
  Pandoc will parse as such, but no metadata field. Thus this filter
  allows you to automatically fill the `thanks`, `abstract` and `keywords`
  fields based on `docx` or other import formats.
- Entering blocks in a metadata YAML block is error-prone for users
  unfamiliar with YAML indentation rules. Allowing them to enter
  these fields in the document itself is easier.

The filter also provides a `reviewof` field intended for book reviews. 

Usage
=====

Use headings to mark out your abstract, acknowledgments, and keywords:

```markdown
---
title: My article
author: Jane E. Doe
---

# Abstract

This is a short and sweet article.

# Keywords

- science
- art

# Thanks

I'm grateful to my parents and family.

# Review of 

[Doe]{.smallcaps}, Jane, *Last but not least*, Fancy Press, 2018, 320 pp.

# Introduction

The article's body starts (and ends) here.
```

* The metadata sections must be at the beginning of the document. 
  The document's body will start wherever the filter encounters a
  horizontal line or a header whose title isn't one of "Abstract" etc. Headers titled "Summary" or the like lower in the document
  will be treated as ordinary document sections. 
* If you don't have a heading (`# Introduction`) to separate the 
  abstract/thanks/keywords from the rest of the text, use a 
  [horizontal rule](#https://pandoc.org/MANUAL.html#horizontal-rules).
  In markdown make sure you leave an empty line before a `---` rule, 
  otherwise the text above is read as a heading.
  In source formats whose horizontal rules are
  not recognized as such by Pandoc (e.g. MS Word), you can still achieve the
  same effect by using a separate paragraph containing only `* * *`. 
* The keyword section must be a bullet point list. 
  Any other content in that section will be ignored.
* Metadata section titles are case-insensitive (`Abstract`, `ABSTRACT`
  and `abstract` all work). Aliases are provided: `Summary` for `Abstract`,
  `Acknowledgements` and `Acknowledgments` for `thanks`. 
* The `abstract`, `keywords` and `thanks` headings can be of any level.
  They will end at the next header, whichever level it is. Thus your document's headers can be 
  of level 2 or lower if you wish: `## Introduction` works just
  as well to terminate the abstract/thanks/keywords. 
