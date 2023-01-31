---
title: "Image attributes: additional image attributes in
  Pandoc's markdown"
author: "Julien Dutant"
---

v0.1 Copyright: © 2022 Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

Provides extra attributes to inline images in Pandoc and
handles them in some output formats.

# Usage

## Installation

Place the file `image-attributes.lua` in a location Pandoc can find 
(e.g., the same folder as your source) and run:

```markdown
pandoc source.md -L image-attributes.lua -o output.pdf
```

## Syntax

In your markdown source, add attributes to the image element:

```markdown
![title](image_file.svg){.center .framed}
```

## Currently supported attributes

### `center`

Center the image. Supported output formats: LaTeX/PDF, HTML, EPUB.

Warning: do not use on images that will be
treated as figures. Images are treating as figure if they have
a caption and are alone in a paragraph, i.e., surrounded by
blank line. See [Pandoc's manual](https://pandoc.org/MANUAL.html#images) for more details.

## Troubleshotting

In LaTeX output, an image followed by a manual line break
will thrown an error. Source code:

```markdown
This: ![](myimage.svg){.center}\
says more than a thousand words.
```

results in `! LaTeX Error: There's no line here to end.`
This will happen in particular if, following [Pandoc's
 anual](https://pandoc.org/MANUAL.html#images)), you're 
 using a manual linebreak to ensure an image is treated 
 as inline even though it's not surrounded by text. 
To avoid this problem, you can use a zero width non-joiner
space--an invisible space char meant to separate ligatures,
encoded `&zwnj;`.
It outputs nothing in LaTeX but prevents Pandoc from 
parsing an image surrounded by blank lines as a floating
figure:

```markdown
The figure below stands between blank lines: 

![](myimage.svg){.center}&zwnj;

But is not turned into a `figure` environment.
```
