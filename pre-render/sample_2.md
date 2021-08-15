---
title: Reflective Equilibrium on the Fringe
author:
- name: Bogdan Dicher
abstract: |
  Reflective equilibrium, as a methodology for the "formation of
  logics," fails on the *fringe*, where intricate details can make or
  break a logical theory. On the fringe, the process of theorification
  cannot be methodologically governed by anything like reflective
  equilibrium. When logical theorising gets tricky, there is nothing on
  the pre-theoretical side on which our theoretical claims can reflect
  of --- at least not in any meaningful way. Indeed, the fringe is
  exclusively the domain of theoretical negotiations and the
  methodological power of reflective equilibrium is merely nominal.
header-includes: |
  ```{=latex}
  \usepackage{amsfonts}
  \usepackage{bussproofs}
  \EnableBpAbbreviations
  ```
---


# Reflective equilibrium


::: pre-render

Suppose now that we go about formalising (arg) in the Fregean syntax ---
our target (tar). We already know its syncategoremata: expressions like
"all", "some", the (grammatical) conjunctions "and", "or", "if ...
then," etc. We also know, by and large, how to deal with them in (tar).
All in all, we could arrive at the following schematic rendering of
(arg): 
$$\AXC{$\forall x Mx$}
\UIC{$Ms$}
\DP$$ 
of which we make sense via a key that says that "$M$" stands for
*mortal*, "$x$" is a variable ranging over the extension of "man", and
"$s$" an individual constant, standing for *Socrates*.
:::

It's no achievement to see that this is a suboptimal --- indeed, plainly
wrong --- formalisation of (arg). For one thing, "All men are mortal" was
rendered formally rather dumbly. For instance, *man* and *mortal* were
placed in distinct grammatical categories. Not only is this unpleasantly
non-uniform, but it also obscures the predicate status of *man*. We
would do better to render this premise as "$\forall x (Wx\to Mx)$", with
"$W$" standing for *man* and $x$ ranging over a (generic) class of
objects. (Note that this is already a good step away from the"surface"
grammar of English.) So we get an improved rendering of (arg), namely:
`$$\AXC{$\forall x (Wx\to Mx)$} \UIC{$Ms$} \DP$$`{.pre-render} 
the validity of which we check in (tar).[^8] Obviously, it is not.

[^8]: Actually, since (tar) is rather imprecise, the validity check
    would have to be performed in a logic based on the Fregean syntax
    or, at the very least, in a fragment of such a logic that contains
    enough information about $\to$, $\forall$, and the horizontal
    "inference" line that ended up rendering "because."

Does this mean that the conclusion of (arg) does not follow logically
from the premise? Well, yes, it does mean that; still, we wouldn't want
to say that "Socrates is mortal" may be false when "All men are mortal"
is true. In this sense, we would not want to revise our commitment to
(arg). We figure out that we need another premise, "Socrates is a man,"
in order to validate both (arg) and its formalisation.

And so on and so forth: I am not particularly bent on boring the reader
with logical trivia. The salient point is that all this happens within
the confines of a more or less precise target formalism. At this level,
of *formalisation*, it is quite plausible to see our endeavours as
governed by **RE**.

::: pre-render
Consider first the case of a working mathematician who believes, in the
first instance, that the $\omega$-rule: $$\AXC{$P(0)$}
\AXC{$P(1)$}
\AXC{$\dots$}
\AXC{$P(n)$}
\AXC{$\dots$}
 \QuinaryInfC{$\forall x (x\in{\mathbb N}\to Px)$}
 \DP$$ is *logically* valid.
:::

Subsequently, and in light of various *2-knowledge* beliefs --- inference
rules are finitary, logic is topic-neutral, "natural number" does not
express a logical property, logicism fails because of Russell's paradox,
etc. --- she changes her mind and decides not only that the $\omega$-rule
is not part of logic, but also that its syntactic structure, and in
particular its infinite number of premises, make it not an inference
rule at all.[^9]

[^9]: This example may also serve to illustrate the modification of
    *1-knowledge* in virtue of *2-knowledge* discussed at the end of the
    previous section.

Take now Peano's axiom of induction. Its natural formulation involves
quantification over properties:
$$\forall P ( P(0) \land \forall n (P(n) \to P(n+1)) \to \forall n P(n) )$$
For various (theoretical) reasons, this kind of formalisation was
thought best to be avoided and first-order logic, in which the
quantifiers range only over individuals, became the norm [for more on
this, see @eklund_m:1996]. The demise of second order formalisms has
little to do with what goes on in natural language, where (apparent)
quantification over properties is certainly present. It was and, to the
extent that the controversy is alive, it still is a matter of deploying
heady theoretical considerations.[^10] Languages may carry logics inside
them, but it is still up to the logicians to decide what to bring to the
surface and how.

[^10]: Famously, Quine rejected second-order logic as set theory "in
    sheep's clothes" [-@quine:1970, 66]. But the same logic was forcefully
    defended by @shapiro_s:1991.

A third example will also illustrate the fact that, in many cases, the
practice is not at all coherent and it cannot light our way in a simple
fashion. Take the following rules governing a truth predicate $T$:
`$$\AXC{$A$}\RightLabel{$T$-I} \UIC{$T\langle A\rangle$} \DP \hskip 20mm \AXC{$T\langle A\rangle$}\RightLabel{$T$-E} \UIC{$A$} \DP$$`{.pre-render} They seem innocuous enough. But add some equally innocuous
reasoning principles and pick the sentence named by $\langle A\rangle$
so that it is "This sentence is false" and all hell breaks loose,
i.e. any sentence follows from any sentence.[^11] Deciding how to handle
these issues significantly exceeds what can be reasonably characterised
as a process of formalisation.

[^11]: For more on this, see below, @sec:st.

Thus, *in practice* the formation of logics is a rough-going process of
theorification responsible to the pre-formal practice, informed by it
and, allegedly at least, placed under its control to a certain extent.
The process goes beyond simple formalisation and is not at all
unproblematic.

**RE** is meant to guide us on the righteous path of smoothing out these
asperities and forming a justified logic, by debunking whatever tensions
may arise between *1-* and *2-knowledge*. Can it really do this? I think
not and in the next three sections, I will explore three cases of
current logical debates, consideration of which will explain why I am
sceptical about the promises of **RE**.

# Case study no.1: Multiple conclusions

::: pre-render
At the
same time, inferences of the form: 
$$\AXC{$\neg\neg A$}\RightLabel{DNE}
\UIC{$A$}
\DP$$ 
are generally accepted in the daily ratiocinative practice. That
is, one tends to accept inferences by *double negation elimination*
(DNE).

DNE is obviously an elimination rule for negation. The corresponding
introduction rule is the (intuitionistic) *reductio ad absurdum*:
$$\AXC{$[A]_{j}$}
\noLine
\UIC{$\vdots$}
\noLine
\UIC{$\neg A$}\RightLabel{iRAA, $j$}
\UIC{$\neg A$}
\DP$$ It turns out that these two rules cannot be harmonised *if*
arguments (and the formal proofs representing them) are
single-conclusion. A familiar, if bitterly contested, account of harmony
has it that a set of introductions and eliminations for a logical
constant is harmonious only if its addition to a proof system is
conservative.[^13] That is, to the extent that the
addition generates new valid arguments, then these must involve the
novel vocabulary. Famously, Peirce's law $$((A\to B)\to A)\to A$$
despite containing only one logical operator, the conditional, is not
provable in intuitionistic logic. *A fortiori*, it is not provable using
only the rules for the conditional. However, once one adds DNE to
intuitionistic logic --- thus ensuring that negation behaves classically
--- there is a proof of it. (I leave the construction of the proof as an
exercise for the reader.) It follows from this that classical negation
is not harmonious. The strongest correct rules for negation are those of
intuitionistic logic.

[^13]: Not much hinges on this contested account of harmony. It features
    here because it is the best known. 

But this holds water only if arguments and the formal proofs
representing them are single-conclusion. Only in this case does
classical negation yield a nonconservative extension of intuitionistic
logic. If multiple conclusions are allowed, classical negation is
conservative and hence harmonious. In such systems there are proofs of
Peirce's law in the implicational fragment alone:
$$\AxiomC{[$A$]$_1$}\RightLabel{W}
\UnaryInfC{$A,B$}\RightLabel{$\to$I, 1}
\UnaryInfC{$A, A\to B$}
\AxiomC{[$(A\to B)\to A$]$_2$}\RightLabel{$\to$E}
\BinaryInfC{$A,A$}\RightLabel{C}
\UnaryInfC{$A$}\RightLabel{$\to$I, 2}
\UnaryInfC{$((A\to B)\to A)\to A$}
\DP$$ Now let us find our way out of this, guided by **RE**. Assume that
our background theory, i.e. the commitment to inferentialism and the
account of harmony as conservativeness, is sacrosanct.
:::


Our starting point is Gentzen's sequent calculus for classical logic,
$LK$\ . Recall that this contains the Cut rule:
`$$\AXC{$X:Y,A$} \AXC{$A,X:Y$} \BIC{$X:Y$} \DP$$`{.pre-render} Now if one were to add e.g. the $T$-rules from above to
$LK$, then the system would become trivial: any conclusion would follow
from any premisses. To see this, let $\lambda$ be a sentence such that
$\lambda \equiv_{df} \neg T\langle \lambda \rangle$. Thus $\lambda$ is
the (strengthened) *Liar*: "This sentence is not true."

::: pre-render
Then we can derive the empty sequent:
$$\AXC{}\RightLabel{Id}
\UIC{$T\langle \lambda\rangle : T\langle \lambda\rangle$}\RightLabel{$\neg$-L, $\neg$-R}
\UIC{$\neg T\langle \lambda\rangle : \neg T\langle \lambda\rangle$}\RightLabel{df}
\UIC{$\lambda : \lambda$}\RightLabel{$T$-L}
\UIC{$T\langle \lambda \rangle : \lambda$}\RightLabel{$\neg$-L}
\UIC{$ : \neg T\langle \lambda \rangle, \lambda$}\RightLabel{df, Contraction}
\UIC{$ : \lambda$}
\AXC{}\RightLabel{Id}
\UIC{$T\langle \lambda\rangle : T\langle \lambda\rangle$}\RightLabel{$\neg$-L, $\neg$-R}
\UIC{$\neg T\langle \lambda\rangle : \neg T\langle \lambda\rangle$}\RightLabel{df}
\UIC{$\lambda : \lambda$}\RightLabel{$T$-R}
\UIC{$\lambda : T\langle \lambda\rangle$}\RightLabel{$\neg$-R}
\UIC{$ \neg T\langle \lambda \rangle, \lambda : $}\RightLabel{df, Contraction}
\UIC{$\lambda : $}\RightLabel{Cut}\BIC{$ : $}\DP$$ 
from which in turn
$A:B$ follows for any $A,B$ via Weakening.
:::
