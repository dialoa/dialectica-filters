---
pre-render:
    scope: selected # change to all to pre-render all instead
    exclude-formats: [latex,markdown] # don't convert in markdown
    header-includes: 
    use-header: false # false will ignore the main header-includes 
author: Julien Dutant
title: Pre-render filter sample document
header-includes: 
- |
  ```{=latex}
  \usepackage{bussproofs}
  ```
---

In this paragraph the equations should not pre-rendered. $$p \rightarrow q 
\models \mathcal{Fa}$$ $$f(x) = \int_{-\infty}^\infty \hat{f}(\xi)\,e^{2 \pi i \xi x}\,d\xi$$

::: pre-render
In this paragraph the equations are pre-rendered: $$p \rightarrow q 
\models \mathcal{Fa}$$ $$f(x) = \int_{-\infty}^\infty \hat{f}(\xi)\,e^{2 \pi i \xi x}\,d\xi$$
in display mode.
:::

Now let's try with inline equations. A couple of inline equation that should not to be pre-rendered: $F = ma$, $E = mc^2$. [The same, now pre-rendered: $F = ma$ and the second $E = mc^2$.]{.pre-render}


