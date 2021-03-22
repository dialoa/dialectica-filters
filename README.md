# Dialectica filters

Pandoc Lua filters used to produce the journal Dialectica.

This repository collects some Lua filters written to produce the
open-access version of the journal [Dialectica](https://dialectica.philosophie.ch).

All filters are under MIT License. See each folder for copyrights.

## Overview

A couple of bigger filters are in separate repositories:

* [columns](https://github.com/jdutant/columns) Multiple columns support in Pandoc's markdown

* [statement](https://github.com/jdutant/statement) Statement support in Pandoc's markdown (IN PROGRESS)

Here you will find:

* [bib-place](bib-place) Template control of the placement of a
document's bibliography when using Pandoc `citeproc` . 

* [first-line-indent](first-line-indent) Finer control of Pandoc's
first-line indent output in HTML and LaTeX. 

* [longtable-to-xtab](longtable-to-xtab) Convert LaTeX
`longtable` environments into `xtab` environments in Pandoc's LaTeX
output (to be used within columns with the columns filter).

* [not-in-format](not-in-format) Keep part of a document out of selected
output formats. Included in [pandoc/lua-filters](https://github.com/pandoc/lua-filters).

And:

* [functions](functions) some functions to be reused across filters.

## Contributions

PR welcome. 

