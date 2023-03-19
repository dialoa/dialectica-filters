# Dialectica filters

Pandoc Lua filters created to produce the journal 
[Dialectica][].

This repository collects some Lua filters written to produce 
the journal [Dialectica][].

[Dialectica]: https://dialectica.philosophie.ch
[columns]: https://github.com/dialoa/columns
[first-line-indent]: https://github.com/dialoa/first-line-indent
[statement]: https://github.com/dialoa/statement
[recursive-citeproc]: https://github.com/dialoa/recursive-citeproc

All filters are under MIT License. See each folder for copyrights.

## List

* [columns][] Multiple columns support

* [statement][] Statement and theorem support

* [first-line-indent][] First-line indentation (LaTeX and HTML output) (Quarto / Pandoc)

* [recursive-citeproc][] Handle self-citing bibliographies (Quarto / Pandoc)

* [labelled-lists](labelled-lists) Custom labelled lists in LaTeX and HTML ouptut.

* [bib-place](bib-place) Template control of the placement of a
document's bibliography when using Pandoc `citeproc` . 

* [longtable-to-xtab](longtable-to-xtab) Convert LaTeX
`longtable` environments into `xtab` environments in Pandoc's LaTeX
output (to be used within columns with the columns filter).

* [not-in-format](not-in-format) Keep part of a document out of selected
output formats. Included in [pandoc/lua-filters](https://github.com/pandoc/lua-filters).


* [prefix-ids](prefix-ids) Adds a prefix to all `identifiers` within a 
   Pandoc document.

And:

* [functions](functions) some functions to be reused across filters.

## Contributions

PR welcome. 

