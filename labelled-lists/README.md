---
title: "Labelled-lists - Custom labelled lists in Pandoc's markdown"
author: "Julien Dutant"
---

Labelled-lists =======

custom labelled lists in Pandoc's markdown.

v0.1. Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

Introduction
------------

This filter provides custom labelled lists in Pandoc's markdown for
outputs in LaTeX/PDF, HTML and JATS XML. Instead of bullets or
numbers, list items are given custom text labels. The text labels can
include markdown formatting. 

Usage
-----

### Loading the filter

The filter is loaded with the Pandoc `-L` or `--lua-filter` option. 

```bash pandoc -L path/to/labelled-lists.lua source.md -o output.html
```

If the filter is in Pandoc's `$DATADIR` there is no need to give its
path. See [Pandoc's manual[
(https://pandoc.org/MANUAL.html#general-options) for details.

### Markdown syntax

A simple illustration of the custom label syntax:

```markdown
* [Premise 1]{} This is the first claim.
* [Premise 2]{} This is the second claim.
* [Conclusion]{} This is the conclusion.
```

This generates the following list (process this file with the filter
to see the result):

* [Premise 1]{} This is the first claim.
* [Premise 2]{} This is the second claim.
* [Conclusion]{} This is the conclusion.

In general, the filter will turn a bullet list into a custom label
list provided that *every item starts with a non-empty Span
element*.

* A Span element is inline text (i.e., not block like a paragraph)
  that optinally has some attributes. The default syntax is `
  [inline text]{attributes}`. Inline text will be used as label, 
  placed within round bracket. 
* There is no need to specify attributes on the Span. But curly
  brackets must be present: `[label]` won't work, `[label]{}` will.
* The label can include formatting. `[**T1**]{}` will generate a label with
  strong emphasis (bold by default).
* For the purposes of this filter, a Span is *non-empty* if its inline
  text is not empty. Thus `[]{}` will not work. Numbers or other unicode
  characters work. To generate an empty
  label, use a space or other invisible character, e.g. `[ ]
  {}`. *Exception*: math formulas will work as labels, but if the inline 
  text only contains LaTeX code (`\textsc{a}`) it will be treated as empty.
* Span elements can also be entered using HTML syntax: `<span>inline text
  </span>`. See [Pandoc manual]
  (https://pandoc.org/MANUAL.html#divs-and-spans) for details. 

Examples and tests
------------------

### math formulas

* [$p_1$]{} This list uses
* [$p_2$]{} math formulas as labels.

### LaTeX code

* [\textbf{a}]{} This list uses
* [\textbf{b}]{} latex code as labels.

Ignored: these are not treated as labels.

### Small caps 

* [[All]{.smallcaps}]{} This list uses
* [[Some]{.smallcaps}]{} latex code as labels.

### List with Para items

* [A1]{} $$F(x) > G(x)$$
* [A2]{} $$G(x) > H(x)$$

### items with several blocks 
* [**B1**]{} This list's items

    consist of several blocks

    $$\sum_i Fi > \sum_i Gi$$

* [**B2**]{} Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et
  massa ut eros volutpat gravida ut vel lacus. Proin turpis eros, imperdiet sed
  quam eget, bibendum aliquam massa. Phasellus pellentesque egestas dapibus.
  Proin porta tellus id orci consectetur bibendum. Nam eu cursus quam. Etiam
  vehicula in mi sed interdum. Duis rutrum eleifend consectetur. Phasellus
  ullamcorper, urna at vestibulum venenatis, tellus erat luctus nibh, eget
  hendrerit justo enim nec magna. Duis mollis ac felis ac tristique.

  Pellentesque malesuada arcu ac orci scelerisque vulputate. Aenean at ex
  suscipit, ultricies tellus sit amet, luctus lectus. Duis ut viverra sapien.
  Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac
  turpis egestas. Cras consequat nisi at ex finibus, in condimentum erat auctor.
  In at nulla at est iaculis pulvinar sed id diam. Cras malesuada sit amet tellus id molestie.

Details
-------

### LaTeX output

```latex
\begin{itemize}
\tightlist

\item[(Premise 1)]

This is the first claim.

\item[(Premise 2)]

This is the second claim.

\item[(Conclusion)]

This is the conclusion.

\end{itemize}
```

### HTML output

HTML output is a `<div>`. Each item is a `<p>` if it's one block long,
  a `<div>` if longer. The label itself is contained in a `<span>`. 

```html
<div class="labelled-lists-list">
  <p class="labelled-lists-item"><span class="labelled-lists-label">(Premise 1)</span> This is the first claim.</p>
  <p class="labelled-lists-item"><span class="labelled-lists-label">(Premise 2)</span> This is the second claim.</p>
  <div class="labelled-lists-item">
    <p><span class="labelled-lists-label">(<strong>Conclusion</strong>)</span> This third item consists of</p>
    <p>two blocks.</p>
  </div>
</div>
```

### List structures

* In the Pandoc AST, each item is a list of blocks. If the item has 
 only one block, the list will contain only one element. 
* If an item has only one block, that block's type can be at least:
  - Plain, if it only contains straightforward markdown
  - Para, if it contains some equation LaTeX code (and perhaps in other
   cases too)
  - Table if it contains a table. 
* It an item has several blocks, they will be Para by default, 
  otherwise of whatever type the block is. 
* If an item is only one block, it is either a Plain element (if it 
  only contains straightforward markdown) or a Para element (if it 
  contains some LaTeX code or equation) 