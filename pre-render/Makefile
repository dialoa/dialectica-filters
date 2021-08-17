DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: html pdf

html: pre-render.lua sample.md expected.html
	@pandoc --standalone --lua-filter pre-render.lua --to=html sample.md \
		| $(DIFF) expected.html -

pdf: sample.md
	@pandoc --standalone sample.md -o expected.pdf

expected.html: pre-render.lua sample.md
	@pandoc --standalone --lua-filter pre-render.lua --to=html sample.md \
	--output expected.html

bitmap: pre-render.lua sample.md expected-bitmap
	@pandoc --standalone --lua-filter pre-render.lua --to=html sample.md \
		-M pre-render-format=bitmap \
		| $(DIFF) expected.html -

expected-bitmap:
	@pandoc --standalone --lua-filter pre-render.lua --to=html sample.md \
		-M pre-render-format=bitmap \
	--output expected.html
	
clean:
	@rm -f *.svg *.png expected.html expected.pdf