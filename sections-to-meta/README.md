# Section-to-meta - Lua filter for Pandoc to capture `abstract`, `thanks` and `keywords` sections in the metadata

The pre-render Lua filter for [Pandoc](https://pandoc.org) picks
up `Abstract`, `Thanks`, `Keywords` sections and places them
in the corresponding metadata fields.

v1.0. Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

Description
===========

Pandoc markdown provides `thanks`, `abstract` and `keywords` metadata 
fields. This filter allows you to specify them as sections in the
document itself. There are two reasons to do this:

- if your source document is e.g. `docx`, you can enter sections that
  Pandoc will parse as such, but no metadata field. Thus this filter
  allows you to automatically fill the `thanks`, `abstract` and `keywords`
  fields based on `docx` or other import formats.
- Entering blocks in a metadata YAML block is error-prone for users
  unfamiliar with YAML indentation rules. Allowing them to enter
  these fields in the document itself is easier.

Usage
=====

Use level 1 headings to mark out abstract, acknowledgements and keywords:

```markdown
---
title: My article
author: Jane E. Doe

# Abstract

This is a short and sweet article.

# Keywords

- science
- art

# Thanks

I'm grateful to my parents and family.

# Introduction

The article's body starts (and ends) here.
```

* The keyword section must be a bullet point list (each keyword on a 
  separate line starting with `- ` or `* `. Any other content in that
  section will be ignored.
* Metadata section titles are case-insensitive (`Abstract`, `ABSTRACT`
  and `abstract` all work). Aliases are provided: `Summary` for `Abstract`,
  `Acknowledgements` and `Acknowledgments` for `thanks`. 
* If you don't have a heading (`# Introduction`) to separate the 
  abstract/thanks/keywords from the rest of the text, use a 
  [horizontal rule](#https://pandoc.org/MANUAL.html#horizontal-rules).
  In source formats whose horizontal rules are
  not recognized as such by Pandoc (e.g. MS Word), you can achieve the
  same effect by using an separate paragraph containing only `* * *`. 
* The `abstract`, `keywords` and `thanks` headings can be of any level.
  They will end at the next header, so your document's headers can be 
  of level 2 or lower if you wish (`## Introduction` will work just
  as well to terminate the abstract/thanks/keywords). 
