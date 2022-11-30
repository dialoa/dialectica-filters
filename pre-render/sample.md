---
pre-render:
    scope: selected # change to all to pre-render all instead
    exclude-formats: [latex,markdown] # don't convert in markdown
    header-includes: | 
        \usepackage{amssymb}
        \usepackage{mathptmx}
    use-header: false # false will ignore the main header-includes 
author: Julien Dutant
title: Pre-render filter sample document
header-includes: 
- |
  \usepackage{tikz}
- |
  ```{=latex}
  \usepackage{mathpazo}
  ```
---

This should not be pre-rendered: 
$$p \rightarrow q \models \mathcal{Fa} $$

::: pre-render
This should be pre-rendered:
$$ f(x) = \int_{-\infty}^\infty \hat{f}(\xi)\,e^{2 \pi i \xi x}\,d\xi $$
in display mode.
:::

Now let's try with inline equations. First inline equation is not to be pre-rendered: $F = ma$. But [the second $E = mc^2$]{.pre-render} should.


