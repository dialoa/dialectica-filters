# Pre-render - Lua filter for Pandoc to convert pre-selected maths elements as vector images

The pre-render Lua filter for [Pandoc](https://pandoc.org) converts
pre-selected (optionally: all) math elements as scalable vector
images (when the target output format is not LaTeX). 

v1.0. Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

Description
===========

Documents in Pandoc's markdown may include LaTeX code for maths.
Non-LaTeX/PDF output formats may support some, but not all, of the
LaTeX math. Converting to MathML, or rendering with KaTeX or MathJAX
only works for core LaTeX code and some popular packages. But turning 
all your document's LaTeX in images is overkill if only a few places 
use exotic LaTeX packages. 

This filter allows you to manually select areas of your document for 
converting math into images. The filter converts math code and raw latex 
elements into vector images (`svg`, for better quality and compatibility).
It uses any LaTeX output parameters specified the document's metadata.

Requirements
============

Relies on [Pandoc](https://pandoc.org) and a LaTeX installation that
includes [pdf2svg](https://github.com/dawbarton/pdf2svg) (included in
TexLive and MikTeX). 

Save the `pre-render.lua` file at a location that Pandoc will find.
See [Pandoc's manual](https://pandoc.org/MANUAL.html#option--lua-filter) on how to use Lua
filters. 

Usage
=====

In our markdown source, embed the math or LaTeX raw code you want to 
pre-render within [native Div or Span elements](https://pandoc.org/MANUAL.html#divs-and-spans) 
with the class `pre-render`. Here is a Div containing a display
math formula:

```markdown
::: {.pre-render}
This paragrah's LaTeX: $$f(x) = \int_{-\infty}^\infty
    \hat{f}(\xi)\,e^{2 \pi i \xi x}
    \,d\xi$$ 
is pre-rendered as an image.
:::
```

A Span containing a math formula:

```markdown
This inline formula, 
[$f(x) = \int_{-\infty}^\infty g(x)\,dx$]{.pre-render},
is pre-rendered as an image.
```

A Div containing a Raw LaTeX code block:

```markdown
::: {.pre-render}
~~~{=latex}
\mycommand{param}
~~~
:::
```

If rendering your LaTeX requires some preamble code (command definitions
or loading packages) these should be included in your
 [document's metadata `header-includes` field](https://pandoc.org/MANUAL.html#extension-yaml_metadata_block).
Since you're using this filter you're probably targeting formats other
that LaTeX, so the LaTeX code in `header-includes` should be embedded
between `\`\`\`{=latex}` and `\`\`\`` lines or `~~~{=latex}` and `~~~`
lines:

```yaml
header-includes: |
    ```{=latex}
    \usepackage{bussproofs}
    ```
```

Alternatively, you can provide preamble code to be used specifically
when generating images with the `pre-render/header-includes` option, see 
advanced usage.

You can also force the filter to pre-render all Math and/or all raw LaTeX
in a document via an option in the document's metadata:

```yaml
pre-render: <all/math/raw>
```

# Advanced usage

The filter can take a range of options. These are specified as a map
within the `pre-render` field of your metadata. Here are the options
with their default values:

```yaml
pre-render:
    scope: selected 
    exclude-formats: latex
    use-header: true
    header-includes: 
    format: svg
```

* `scope` (alias `pre-render-scope`): string `all` pre-renders all
     math and raw LaTeX, `math`
    all and only math, `raw` all and only raw, `none` none (deactivates
    the filter), `selected` only the elements within `pre-render` Div
    or Spans (default).
* `exclude-formats`: string or list of strings, 
  [Pandoc output formats names](https://pandoc.org/MANUAL.html#). The 
  filter will pre-render for all output formats not on that list. 
  Specify several as a comma-separated list within brackets, e.g. 
  `[latex, docx, epub]`. By default only `LaTeX/PDF` is excluded.
* `use-header` (alias `pre-render-use-header`): by default
    the filter treats any LaTeX code in the document metadata's main
    `header-includes` field as LaTeX preamble code to generate 
    pdfs converted into images. Set this to `false` to prevent
    this behaviour.
* `header-includes`: allows you to specify LaTeX preamble code that will 
  be used to generated image. Works like Pandoc's `header-includes`
  field, and is combined with it unless `use-header` is `false`. 
  In the LaTeX preamble this will come before the `header-includes`
  code.
* `inkscape`: uses inkscape rather than `pdf2svg` when present. NB: 
  `inkscape` is enforced when the image `format` is set to `png` (aka
  `bitmap` or `raster`).
* `format`: if set to `png` or `raster` or `bitmap`, the pre-rendered
  images will be in `png` format (a bitmap image format) rather than
  `svg` (a vector image format). This option is enforced when generating
  Word, Powerpoint or RTF documents, as these require bitmap rather than
  vector graphics. Case-insensitive.

Example: your document uses the LaTeX package `xcolor` when producing
LaTeX/PDF output, and `bussproofs` to typeset logic proofs. When generating
e-book outputs, you need to convert the logic proofs into bitmap images
but you don't want to use colour. You set-up pre-render to convert selected
LaTeX math into bitmap images, without using the document's header-includes 
but specifying a header-includes for pre-rendered elements:

```yaml
title: Logic article
author: Jane E. Doe
header-includes: |
    ```{=latex}
    \usepackage{xcolor}
    \usepackage{bussproofs}
    ```
pre-render:
    scope: selected
    format: bitmap
    use-header: false
    header-includes: |
        ```{=latex}
        \usepackage{bussproofs}
        ```
```

Simple options have an alias of the form `pre-render-OPTION`, e.g. 
`pre-render-use-header`. This allows you to speficy them directly
on the command line with the `-M` option:

```bash
pandoc -L pre-render -M pre-render-scope=none
```

The alias prevails if both it and the `pre-render` sub-options are 
specified. This allows you to override a document's metadata 
from the command line. Options with aliases are: `scope`, `use-header`, 
`format`, `inkscape`.

Note that `header-includes` and `pre-render/header-includes` are treated by 
Pandoc as markdown. Pandoc will normally recognize LaTeX commands as 
such, so they will work with bare LaTeX commands:

```yaml
pre-render:
    header-includes: \usepackage{xcolor}
```

But if you want to make sure that the content is passed to LaTeX as is
(e.g. if it includes LaTeX comments), it's safer to place it
  `\`\`\`{=latex}` and `\`\`\`` lines or `~~~{=latex}` and `~~~`:

```yaml
pre-render:
    preamble: |
    ```{=latex}
    \usepackage{xcolor} % fancy color options
    ```
```

# Notes for developers

This may be useful if you modify the filter for your purposes.

* `MathJAX` picks up math formulas (in `$...$`, `$$...$$`, `\
  (...\)`, `\[...\]`) within the HTML text, without need for specific
  html tags. It also picks MathML tags.
* in HTML output, `pandoc` wraps maths formulas in markdown with 
  `<span class="math inline">` and `<span class="math display">` tags.
* best use related but image specific classes to allow CSS control
  without breaking already existing css that target those spans. In 
  this filter we add `<span class="imagemath inline">` and `<span
  class="imagemath display">`.
* HTML formatting. The perfect size for those images is: `height: 0.9em;`.

Removing the Div and Spans?

* you cannot replace the `pre-render` Div with a paragraph. 
    Suppose the Div contains a list. In `html`, `<p>` tags cannot
    contain lists. 
* better leave the Div and Spans in case they'be been created with
  additional attributes with further purpose? QU: this incites using
  those divs in the ouputs. But it might be fine, as divs and spans
  are officially invisible.
