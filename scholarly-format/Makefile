PHONY: html tex

html: sample.html 
tex: sample.tex 
pdf: sample.pdf
json: sample.json
native: sample.native 
md: processed.md 

sample.html: sample.md scholarly-format.lua templates/template.html
	@pandoc -L scholarly-metadata.lua \
		-L scholarly-format.lua \
		--template templates/template.html \
		-o $@ $<

sample.tex: sample.md scholarly-format.lua templates/template.latex
	@pandoc -L scholarly-metadata.lua \
		-L scholarly-format.lua \
		--template templates/template.latex \
		--standalone \
		-o $@ $<

sample.pdf: sample.md scholarly-format.lua templates/template.latex
	@pandoc -L scholarly-metadata.lua \
		-L scholarly-format.lua \
		--template templates/template.latex \
		--standalone \
		-o $@ $<

sample.json: sample.md scholarly-format.lua
	@pandoc -L scholarly-metadata.lua \
		-L scholarly-format.lua \
		--standalone -t json \
		-o $@ $<

sample.native: sample.md scholarly-format.lua
	@pandoc -L scholarly-metadata.lua \
		-L scholarly-format.lua \
		--standalone -t native \
		-o $@ $<

processed.md: sample.md scholarly-format.lua
	@pandoc -L scholarly-metadata.lua \
		-L scholarly-format.lua \
		--standalone -t markdown \
		-o $@ $<
