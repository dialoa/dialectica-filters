DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_latex test_html
	@echo Tests complete.

recreate: expected.html expected.tex

pdf: output.pdf

test_html: sample.md recursive-citeproc.lua
	@pandoc -s --lua-filter recursive-citeproc.lua --citeproc --to=html $< \
		| $(DIFF) expected.html -

test_latex: sample.md recursive-citeproc.lua
	@pandoc -s --lua-filter recursive-citeproc.lua --citeproc --to=latex $< \
		| $(DIFF) expected.tex -

expected.html: sample.md recursive-citeproc.lua
	pandoc -s --lua-filter recursive-citeproc.lua --citeproc --output $@ $<

expected.tex: sample.md recursive-citeproc.lua
	pandoc -s --lua-filter recursive-citeproc.lua --citeproc --output $@ $<

output.pdf: sample.md recursive-citeproc.lua
	pandoc -s --lua-filter recursive-citeproc.lua --citeproc --output $@ $<

