---
title: Test prefix-ids filter
linkReferences: true
codeBlockCaptions: true
references:
- type: article-journal
  id: WatsonCrick1953
  author:
  - family: Watson
    given: J. D.
  - family: Crick
    given: F. H. C.
  issued:
    date-parts: 
    - [1953,4,25]
  title: 'Molecular structure of nucleic acids: a structure for
    deoxyribose nucleic acid'
  container-title: Nature
  volume: 171
  issue: 4356
  page: 737-738
  DOI: 10.1038/171737a0
  language: en-GB
---

# Introduction {#sec:intro}

[This span's id]{#ref} is changed. This[introduction] link, or again [as a full-blown link](#introduction) is changed. We handle citations too [@WatsonCrick1953]. 

![Caption](file.ext){#fig:image}

$$x + 2$$ {#eq:myeq}

Pandoc-crossref references: [@sec:intro], [@fig:image], [@eq:myeq].

a   b   c
--- --- ---
1   2   3
4   5   6

: Caption {#tbl:label}

# Code blocks

Can be numbered:

```{#lst:numberedcode .haskell caption="Listing caption"}
main :: IO ()
main = putStrLn "Hello World!"
```

Or use table syntax to get captions, with label as an id attribute: 

```{#lst:mycode .haskell}
main :: IO ()
main = putStrLn "Hello World!"
```

: Listing caption

Or with label specified in the caption:

```haskell
main :: IO ()
main = putStrLn "Hello World!"
```
: Listing caption {#lst:code}

See @tbl:label or @lst:numberedcode or @lst:code or @lst:mycode. 