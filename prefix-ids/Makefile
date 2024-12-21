DIFF ?= diff --strip-trailing-cr -u

FILTERS:= crossref-prefix.lua prefix-ids.lua
PANDOC ?= pandoc

.PHONY: test
test: test-html test-tex

.PHONY: generate
generate: expected.html expected.tex

.PHONY: test-html
test-html: sample.md $(FILTERS)
	@$(PANDOC) -L crossref-prefix.lua -F pandoc-crossref \
	--citeproc -L prefix-ids.lua sample.md \
	--to=html | $(DIFF) expected.html -

.PHONY: test-tex
test-tex: sample.md $(FILTERS)
	@$(PANDOC) -L crossref-prefix.lua -F pandoc-crossref \
	--citeproc -L prefix-ids.lua sample.md \
	--to=latex | $(DIFF) expected.tex -

expected.html: sample.md $(FILTERS)
	@$(PANDOC) -L crossref-prefix.lua -F pandoc-crossref \
	--citeproc -L prefix-ids.lua sample.md \
	--output expected.html

expected.tex: sample.md $(FILTERS)
	@$(PANDOC) -L crossref-prefix.lua -F pandoc-crossref \
	--citeproc -L prefix-ids.lua sample.md \
	--output expected.tex
