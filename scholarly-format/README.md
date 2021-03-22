Author info blocks in pandoc's markdown
=======================================

## Design options

1. Pass the metadata to LaTeX. The LaTeX package handles generating author lists, supscripts etc.
    a. Good: useful latex package for LaTeX users.
    b. Bad: needs to reimplement for other output formats. E.g., a bit of javascript to set variable values in HTML.
2. Pass the lists, etc. as metadata variables to the pandoc template(s). 
    a. Good: formats can be obtained by pandoc templates. 
    b. Good: can target all output formats. 
3. Put the formatted author block in the document (author-info-block). 
    a. Good: no need for a custom template.
    b. Good: covers all output formats. 
    b. Bad: no customization. 

Opting for (3) by default with an option to activate (2). Providing an option in the document:

```yaml
authorinfoblock:
    - customize: yes
```

With `false` default. When activated, `author-info-block` merely provides metadata variables (placed within `author`, `institute` and `authorinfoblock`) to be used by custom latex templates. 

The variables can provide formatting ()

## Options needed

- custom templates. (Default false, prints the result in the document structure as with the present author-info-block). 
- don't add a footmark to author/affiliation if there's only one affiliation or one author.
    + solution: use the superscript style, the filter leave sups empty when there's only one author.
- choose superscript style: numbered/alphabetical/symbolic.
    + Controlled by template, or document? If template, we need to supply a lot of redundant metadata. If document only, people need to set the variable (CLI, defaults, doc) in addition to selecting a custom template. What about: both?
- choose correspondence email icon.
- choose ORCID icon. 

Tentative menu of metadata options:

```yaml
authorinfoblock:
    customize: yes
    affiliationmarkstyle: arabic
localize:
    lastand: "et"
    corresponding: "✉"
    equalcontributionsentence: "Ces auteurs ont contributé à part égale."
```


## Metadata object model

Terminology used below: "list" = indexed list (array); "map" = key-value list (hash, dictionary); "inlines" = inline content, ay include emphasis markup, formulas, URL etc; "blocks" = block content, may include paragraphs, code listings, quotations, tables ...

## Volume or publication-specific

Should be set at the level of a house style or a journal / volume style:

- localize
    + lastand: string. The last `and` in a list.
    + corresponding: string. The envelope symbol.
    + equallycontributed: Inlines. the "equally contributed" claim.

### Document-specific

- title: Inlines (mandatory)
- abstract: Blocks (optional)
- author: Author List (see below) (optional, cf chapter in a book)
- institute: Institution List (see below) (optional, some journals ignore it)

Author and institution list, as in pandoc's scholarly-metadata. 

- author:
    + id: String. (mandatory, not sure what it's for, automatically generated based on the name)
    + name: Inlines. (mandatory) NB, we could offer a map option here (first name, last name)
    + institute: list of Indices. (to the institute table below) (optional)
    + email: String. (optional) 
    + correspondence: boolean (optional)
    + equal_contributor: boolean (optional)
    + ...: can add arbitrary key / value pairs. I suggest adding:
    + shortname: string. For the toc / header. (optional, defaults to tocname, headername or name)
    + tocname: string. To be used in toc. (optional, defaults to shortname)
    + headername: string. To be use in page headers. (optional, defaults to shortname)
    + ORCID: String. (optional)
- institute:
    + id: String. (Used in the source to pair authors with institutes) 
    + index: Number. (Used in the author metadata)
    + name. Inlines. 


## Templates examples

Examples given in HTML. Easy to adapt.

### One-line list of authors, without superscripts

Needs:

* `author.institute.name` for each institute in the author's entry
* `author.isfirst`, `author.islast` for the first and last author of the list. 
* `localize.lastand` localization for the "and" that marks the last item in a list (e.g. "&" or "und").

```markdown
<div class=authorsline>
$for(author)$
$if(author.isfirst)$$elseif(author.islast)$, $localize.lastand$ $else$, $endif$
$if(author.ORCID)$<img src="ORCID.png" alt="ORCID link" />$endif$<span class="authorname">$author.name$</span>$if(author.institute)$, 
$for(author.institute)$
<span class="institutename">$author.institute.name$</span>$sep$,
$endfor$$endif$$endfor$.
</div>
```

The option below does not work: it looks as if within the `$sep$` part `$if(author.penultimate)$` doesn't ever return true as it does outside. 

```markdown
<div class=authorsline>
$for(author)$
<span class="authorname">$author.name$</span>$if(author.institute)$, 
$for(author.institute)$
<span class="institutename">$author.institute.name$</span>$sep$,
$endfor$$endif$$sep$$if(author.penultimate)$, and $else$, $endif$$endfor$.
</div>
```

### One-line list of authors, with superscripts

Needs:

* `author.nameandsuperscript`.  
* Optionally, `author.nameandarabicsuperscript`, and the same for roman and arabic. Could be a map: `author.nameandsuperscript.default/arabic/roman/symbol` .  
As above, replacing `author.name` with `author.namesuperscript`. 

Problem: some journals don't print the affiliations in all formats. E.g. in PDF, "the full list of affiliation is online". We still need the affiliations in the metadata (for other formats), but we should provide:

* `author.nameandsupescript.noaffiliations`

*Better proposal*: provide "author.affiliationmark" and "institute.mark" and "author.romanaffiliationmark", "author.symbolicaffiliationmark" etc.

"The list of author affiliations is available in the full article online."

* Localizations: mark for correspondence. Doesn't even need to be a superscript.

### List of affiliations, without superscripts

Needs:

* `institute.address` (optional)

```markdown
<div class="affiliationsline">
$for(institute)$$institute.name$$if(institute.address)$$institute.address$$sep$, $endfor$.
</div>
```

### One-line list of authors, with superscripts

Needs:

* `institute.nameandsuperscript`.  

### Equal contribution

* Localization: mark for equal contributor. Doesn't even need to be a superscript.

```markdown
$if(authorinfoblock.hasequalcontributors)$$localize.equalcontributionmark$ $localize.equalcontributionsentence$
$endif$
```

### One block per author

Needs

* finer control on which email addresses are printed?

```makrdown
$for(author)$
<p class="authorblock">
$author.name$$if(author.institute)$<br/>
$for(author.institute)$
<span class="institutename">$author.institute.name$</span>
$if(institute.address)$<br/>$institute.address$$endif$
$if(author.email)$<br/>$author.email$$endif$
$sep$<br/>
$endfor$$endif$
</p>
$endfor$
```

