DIFF ?= diff --strip-trailing-cr -u

.PHONY: all

all: html tex pdf

allbutpdf: html tex

pdf: sample.md image-attributes.lua
	@echo Generating output.pdf
	@pandoc -s --lua-filter image-attributes.lua --to=pdf $< \
		--output output.pdf

tex: sample.md expected.tex image-attributes.lua
	@pandoc -s --lua-filter image-attributes.lua --to=latex $< \
		| $(DIFF) expected.tex -

html: sample.md expected.html image-attributes.lua
	@pandoc -s --lua-filter image-attributes.lua --to=html $< \
		| $(DIFF) expected.html -

expected.html: sample.md image-attributes.lua
	pandoc -s --lua-filter image-attributes.lua --to=html $< \
		--output $@

expected.tex: sample.md image-attributes.lua
	pandoc -s --lua-filter image-attributes.lua --to=latex $< \
		--output $@
