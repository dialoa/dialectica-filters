DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: html pdf

html: pre-render.lua sample.md expected.html
	@pandoc --lua-filter pre-render.lua --to=html sample.md \
		| $(DIFF) expected.html -

pdf: sample.md
	@pandoc sample.md -o expected.pdf

expected.html: pre-render.lua sample.md
	@pandoc --lua-filter pre-render.lua --to=html sample.md \
	--output expected.html

clean:
	@rm *.svg expected.html expected.pdf