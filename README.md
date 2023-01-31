# Dialectica filters

Pandoc Lua filters created to produce the journal Dialectica.

This repository collects some Lua filters written to produce the
open-access version of the journal
[Dialectica](https://dialectica.philosophie.ch).

All filters are under MIT License. See each folder for copyrights.

## List

* [columns](columns) Multiple columns
  support

* [statement](statement) Statement and theorem support

* [indentation](intentation) First-line indentation (LaTeX and HTML output)

* [labelled-lists](labelled-lists) Custom labelled lists in LaTeX and HTML ouptut.

* [bib-place](bib-place) Template control of the placement of a
document's bibliography when using Pandoc `citeproc` . 

* [longtable-to-xtab](longtable-to-xtab) Convert LaTeX
`longtable` environments into `xtab` environments in Pandoc's LaTeX
output (to be used within columns with the columns filter).

* [not-in-format](not-in-format) Keep part of a document out of selected
output formats. Included in [pandoc/lua-filters](https://github.com/pandoc/lua-filters).

* [recursive-citeproc](recursive-citeproc) Handle self-citing bibliographies.

* [prefix-ids](prefix-ids) Adds a prefix to all `identifiers` within a 
   Pandoc document.

And:

* [functions](functions) some functions to be reused across filters.

## Contributions

PR welcome. 

