DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_latex test_html

recreate: expected.tex expected.html 

pdf: output.pdf

test_html: README.md labelled-lists.lua
	@pandoc -s --lua-filter labelled-lists.lua --to=html $< \
		| $(DIFF) expected.html -

test_latex: README.md labelled-lists.lua
	@pandoc -s --lua-filter labelled-lists.lua --to=latex $< \
		| $(DIFF) expected.tex -

expected.html: README.md labelled-lists.lua
	pandoc -s --lua-filter labelled-lists.lua --output $@ $<

expected.tex: README.md labelled-lists.lua
	pandoc -s --lua-filter labelled-lists.lua --output $@ $<

output.pdf: README.md labelled-lists.lua
	@pandoc -s --lua-filter labelled-lists.lua --output $@ $<

