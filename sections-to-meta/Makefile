DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: markdown docx

regenerate: expected.md expected-docx.md

markdown: sections-to-meta.lua sample.md
	@pandoc --standalone --lua-filter sections-to-meta.lua --to=markdown sample.md \
		| $(DIFF) expected.md -

docx: sections-to-meta.lua docxsample.docx
	@pandoc --standalone --lua-filter sections-to-meta.lua --to=markdown docxsample.docx \
		| $(DIFF) expected-docx.md -

expected.md: sections-to-meta.lua sample.md
	@pandoc --standalone --lua-filter sections-to-meta.lua --to=markdown sample.md \
	--output expected.md

expected-docx.md: sections-to-meta.lua docxsample.docx
	@pandoc --standalone --lua-filter sections-to-meta.lua --to=markdown docxsample.docx \
	--output expected-docx.md

clean:
	@rm -f expected.md expected-docx.md