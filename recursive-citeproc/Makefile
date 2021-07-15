DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_latex test_html

test_html: sample.md expected.html recursive-citeproc.lua
	@pandoc -s --lua-filter recursive-citeproc.lua --citeproc --to=html $< \
		| $(DIFF) expected.html -

test_latex: sample.md expected.tex recursive-citeproc.lua
	@pandoc -s --lua-filter recursive-citeproc.lua --citeproc --to=latex $< \
		| $(DIFF) expected.tex -

expected.html: sample.md recursive-citeproc.lua
	pandoc -s --lua-filter recursive-citeproc.lua --citeproc --output $@ $<

expected.tex: sample.md recursive-citeproc.lua
	pandoc -s --lua-filter recursive-citeproc.lua --citeproc --output $@ $<

pdf: sample.md recursive-citeproc.lua
	@pandoc -s --lua-filter recursive-citeproc.lua --citeproc --output out.pdf $<

