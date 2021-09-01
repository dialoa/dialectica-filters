DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: html tex

html: prefix-ids.lua sample.md expected.html
	@pandoc -L prefix-ids.lua -F pandoc-crossref --to=html sample.md \
		| $(DIFF) expected.html -

tex: prefix-ids.lua sample.md expected.tex
	@pandoc -L prefix-ids.lua -F pandoc-crossref --to=latex sample.md \
		| $(DIFF) expected.tex -

expected.html: prefix-ids.lua sample.md
	@pandoc -L prefix-ids.lua -F pandoc-crossref --to=html sample.md \
	--output expected.html

expected.tex: prefix-ids.lua sample.md
	@pandoc -L prefix-ids.lua -F pandoc-crossref --to=latex sample.md \
	--output expected.tex
