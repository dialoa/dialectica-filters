DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_latex test_html

test_html: README.md expected.html labelled-lists.lua
	@pandoc --lua-filter labelled-lists.lua --to=html $< \
		| $(DIFF) expected.html -

test_latex: README.md expected.tex labelled-lists.lua
	@pandoc --lua-filter labelled-lists.lua --to=latex $< \
		| $(DIFF) expected.tex -

expected.html: README.md labelled-lists.lua
	pandoc --lua-filter labelled-lists.lua --output $@ $<

expected.tex: README.md labelled-lists.lua
	pandoc --lua-filter labelled-lists.lua --output $@ $<

pdf: README.md labelled-lists.lua
	@pandoc --lua-filter labelled-lists.lua --output out.pdf $<

