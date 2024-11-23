# Dialectica filters

Pandoc Lua filters created to produce the journal 
[Dialectica][].

This repository collects some Lua filters written to produce 
the journal [Dialectica][].

All filters are under MIT License. See each folder for copyrights.

## List

* [columns] Multiple columns support

* [statement] Statement and theorem support

* [imagify] Imagify LaTeX elements for HTML output

* [labelled-lists] Custom labelled lists in LaTeX and HTML output.

* [first-line-indent] First-line indentation (LaTeX and HTML output) (Quarto / Pandoc)

* [recursive-citeproc] Handle self-citing bibliographies (Quarto / Pandoc)

* [bib-place](bib-place) Template control of the placement of a
document's bibliography when using Pandoc `citeproc` . 

* [not-in-format](not-in-format) Keep part of a document out of selected
output formats. Included in [pandoc/lua-filters](https://github.com/pandoc/lua-filters).

* [secnumdepth](secnumdepth) Enables the `secnum-depth` variable
   in formats other than LaTeX. (h/t [tarleb](https://github.com/jgm/pandoc/issues/6459#issuecomment-1112189237))

* [prefix-ids](prefix-ids) Adds a prefix to all `identifiers` within a 
   Pandoc document.

And:

* [longtable-to-xtab](longtable-to-xtab) Convert LaTeX
`longtable` environments into `xtab` environments in Pandoc's LaTeX
output. (Project for an enhancement of the columns filter).

* [functions](functions) some functions to be reused across filters.

## Contributions

PR welcome. 


[Dialectica]: https://dialectica.philosophie.ch
[statement]: https://github.com/dialoa/statement
[columns]: https://github.com/dialoa/columns
[imagify]: https://github.com/dialoa/imagify
[labelled-lists]: https://github.com/dialoa/labelled-lists
[first-line-indent]: https://github.com/dialoa/first-line-indent
[recursive-citeproc]: https://github.com/dialoa/recursive-citeproc
