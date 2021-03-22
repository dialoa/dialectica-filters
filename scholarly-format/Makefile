PHONY: html tex

html: sample.html

tex: sample.tex

json: sample.json

native: sample.native

sample.html: sample.md
	@pandoc -L scholarly-metadata.lua \
		-L scholarly-format.lua \
		--template template.html \
		-o $@ $<

sample.tex: sample.md
	@pandoc -L scholarly-metadata.lua \
		-L author-info-blocks.lua \
		--standalone \
		-o $@ $<

sample.json: sample.md
	@pandoc -L scholarly-metadata.lua \
		--standalone -t json \
		-o $@ $<

sample.native: sample.md
	@pandoc -L scholarly-metadata.lua \
		--standalone -t native \
		-o $@ $<
