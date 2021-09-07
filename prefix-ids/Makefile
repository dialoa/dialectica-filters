DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: html tex

html: crossref-prefix.lua prefix-ids.lua sample.md expected.html
	@pandoc -L crossref-prefix.lua -F pandoc-crossref \
	--citeproc -L prefix-ids.lua sample.md \
	--to=html | $(DIFF) expected.html -

tex: crossref-prefix.lua prefix-ids.lua sample.md expected.tex
	@pandoc -L crossref-prefix.lua -F pandoc-crossref \
	--citeproc -L prefix-ids.lua sample.md \
	--to=latex | $(DIFF) expected.tex -

expected.html: crossref-prefix.lua prefix-ids.lua sample.md
	@pandoc -L crossref-prefix.lua -F pandoc-crossref \
	--citeproc -L prefix-ids.lua sample.md \
	--output expected.html

expected.tex: crossref-prefix.lua prefix-ids.lua sample.md
	@pandoc -L crossref-prefix.lua -F pandoc-crossref \
	--citeproc -L prefix-ids.lua sample.md \
	--output expected.tex
